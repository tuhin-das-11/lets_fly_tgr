# 🔒 LET'S FLY TGR — Security Policy

> **Version:** 1.0.0
> **Last Updated:** 2026-11-21
> **Maintainer:** LET'S FLY TGR Security Team

This document describes the security architecture, policies, and best practices for the **LET'S FLY TGR** application. All contributors, reviewers, and deployers **must** read and follow this guide.

---

## Table of Contents

1. [Authentication Security](#1-authentication-security)
2. [API Key Management](#2-api-key-management)
3. [Row Level Security (RLS)](#3-row-level-security-rls)
4. [Data Protection](#4-data-protection)
5. [Network Security](#5-network-security)
6. [App-Blocking Ethics](#6-app-blocking-ethics)
7. [Privacy](#7-privacy)
8. [Credential Configuration Guide](#8-credential-configuration-guide)
9. [Security Checklist for Releases](#9-security-checklist-for-releases)
10. [Vulnerability Reporting](#10-vulnerability-reporting)

---

## 1. Authentication Security

### 1.1 Supabase Auth with JWT

LET'S FLY TGR uses **Supabase Auth** as its identity provider. Every authenticated request carries a signed **JSON Web Token (JWT)**.

- **JWT Signing:** Tokens are signed server-side by Supabase using the project's JWT secret. The client never possesses or accesses this secret.
- **Token Lifetime:** Access tokens have a short TTL (default: 3600 seconds / 1 hour). This limits the blast radius of a leaked token.
- **Claims:** The JWT `sub` claim maps to `auth.uid()` in Postgres and is the foundation of all Row Level Security policies.

### 1.2 Token Storage

```
┌─────────────────────────────────────────────┐
│          flutter_secure_storage              │
│  ┌───────────────┐  ┌────────────────────┐  │
│  │  Access Token  │  │  Refresh Token     │  │
│  │  (short-lived) │  │  (long-lived)      │  │
│  └───────────────┘  └────────────────────┘  │
│  Encrypted via:                              │
│    • iOS  → Keychain                         │
│    • Android → EncryptedSharedPreferences    │
│      (AES-256 + Android Keystore)            │
│    • Web → Secure HTTP-only cookie fallback  │
└─────────────────────────────────────────────┘
```

- **Never** store tokens in `SharedPreferences`, `localStorage`, or plain-text files.
- Use [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) for all credential persistence.
- On Android, set `AndroidOptions(encryptedSharedPreferences: true)` to enforce AES-256 encryption backed by Android Keystore.

### 1.3 Token Refresh

- The Supabase client SDK handles **automatic token refresh** via the refresh token before the access token expires.
- On refresh failure (e.g., revoked session), the user is redirected to the login screen and all local tokens are purged.
- Refresh tokens are **single-use and rotated** on every refresh to prevent replay attacks.

### 1.4 Session Management

| Aspect | Policy |
|---|---|
| Session persistence | Tokens persisted across app restarts via `flutter_secure_storage` |
| Logout | Calls `supabase.auth.signOut()`, clears all local tokens, invalidates the refresh token server-side |
| Inactivity timeout | Configurable; default is to respect the Supabase JWT TTL |
| Force logout | Admins can revoke all sessions for a user via the Supabase dashboard |

### 1.5 Multi-Device Support

- Each device gets its own independent session (access + refresh token pair).
- Signing out on one device does **not** automatically sign out other devices, unless the admin explicitly revokes all sessions.
- Users can view active sessions (future feature) and revoke individual device sessions.
- Refresh token rotation ensures that a compromised token on one device cannot be reused if the legitimate device refreshes first.

---

## 2. API Key Management

### 2.1 Key Types and Exposure Rules

| Key | Exposure | Usage |
|---|---|---|
| `SUPABASE_ANON_KEY` | ✅ Safe for client | Included in the Flutter app. Grants only the permissions allowed by RLS policies. |
| `SUPABASE_SERVICE_ROLE_KEY` | 🚫 **Never in client code** | Bypasses RLS. Used **only** in Supabase Edge Functions or trusted server-side environments. |
| `SUPABASE_JWT_SECRET` | 🚫 **Never in client code** | Used only server-side for custom JWT verification if needed. |
| Third-party API keys (AI, Notion, Google) | 🚫 **Never in client code** | Proxied through Edge Functions. See [Section 8](#8-credential-configuration-guide). |

### 2.2 Rules

1. **Never commit secrets to version control.** All secrets live in `.env` files that are listed in `.gitignore`.
2. **Never embed `service_role` key in Flutter code.** Even obfuscated, it can be extracted from APK/IPA bundles.
3. **Use Supabase Edge Functions** to proxy any operation that requires elevated privileges or third-party API keys.
4. **Rotate keys immediately** if any key is suspected of being compromised. Supabase allows key regeneration from the dashboard.
5. **CI/CD secrets** must be stored in the pipeline's encrypted secret store (e.g., GitHub Actions Secrets) and injected at build time.

### 2.3 Edge Function Pattern

```
Client (anon key + JWT)
   │
   ▼
Supabase Edge Function
   ├── Verifies JWT (auth.uid())
   ├── Reads SERVICE_ROLE_KEY from env
   ├── Performs privileged DB operation or third-party API call
   └── Returns sanitized response to client
```

---

## 3. Row Level Security (RLS)

### 3.1 Policy: RLS on Every Table

> [!CAUTION]
> **Every table in the `public` schema MUST have RLS enabled.** A table without RLS is accessible to anyone with the `anon` key.

```sql
-- Enable RLS on a table
ALTER TABLE public.my_table ENABLE ROW LEVEL SECURITY;

-- Force RLS even for the table owner (prevents accidental bypass)
ALTER TABLE public.my_table FORCE ROW LEVEL SECURITY;
```

### 3.2 Policy Design Principles

All policies are anchored to `auth.uid()` — the authenticated user's ID extracted from the JWT.

```sql
-- Example: Users can only read their own data
CREATE POLICY "Users can view own data"
  ON public.user_profiles
  FOR SELECT
  USING (auth.uid() = user_id);

-- Example: Users can only insert rows for themselves
CREATE POLICY "Users can insert own data"
  ON public.user_profiles
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Example: Users can only update their own rows
CREATE POLICY "Users can update own data"
  ON public.user_profiles
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Example: Users can only delete their own rows
CREATE POLICY "Users can delete own data"
  ON public.user_profiles
  FOR DELETE
  USING (auth.uid() = user_id);
```

### 3.3 Testing Strategy

| Test Type | Method |
|---|---|
| **Unit test (SQL)** | Use `pgTAP` or raw SQL test scripts to verify policies. Set `request.jwt.claim.sub` to simulate different users. |
| **Integration test** | From the Flutter app or a test client, authenticate as User A and attempt to read/write User B's data — must fail with a permissions error. |
| **Audit** | Before every release, run the RLS audit query below to find unprotected tables. |

```sql
-- RLS audit: Find tables in 'public' schema without RLS enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND rowsecurity = false;
```

> A non-empty result from this query **blocks the release** until all listed tables have RLS enabled.

---

## 4. Data Protection

### 4.1 Input Validation

- **Client-side:** Validate all user inputs in Flutter (form validators, regex, length limits) for UX responsiveness.
- **Server-side:** **Always** re-validate on the backend (Edge Functions, database constraints, `CHECK` constraints). Client-side validation is a convenience, never a security boundary.
- **Allowlisting over denylisting:** Define what is allowed rather than trying to block known-bad inputs.

### 4.2 SQL Injection Prevention

- **Parameterized queries only.** The Supabase client SDK uses parameterized queries by default. Never concatenate user input into raw SQL strings.
- **Edge Functions** must use the Supabase client library (which parameterizes) or explicitly parameterize any raw SQL via `supabase.rpc()`.
- **Database functions:** Any custom Postgres function that accepts text parameters must use `EXECUTE ... USING` for dynamic SQL (never string concatenation).

```sql
-- ✅ SAFE: Parameterized
SELECT * FROM users WHERE id = $1;

-- 🚫 UNSAFE: String concatenation
EXECUTE 'SELECT * FROM users WHERE id = ' || user_input;
```

### 4.3 XSS Prevention

- **Flutter mobile/desktop:** Native Flutter widgets do not render arbitrary HTML, so traditional XSS is not a primary vector. However:
  - Sanitize any user-generated content before displaying it, especially in `WebView` or `Html` widgets.
  - Never use `dart:html` to inject unsanitized strings into the DOM (Flutter web).
- **Edge Functions (Deno):** Any Edge Function that returns HTML must escape all user-supplied values.
- **Content Security Policy:** For Flutter web builds, set a strict CSP header that disallows inline scripts.

### 4.4 Local Data Encryption

| Data | Storage | Encryption |
|---|---|---|
| Auth tokens | `flutter_secure_storage` | AES-256 (Android Keystore / iOS Keychain) |
| Cached user data | Local SQLite (if used) | Encrypt with [`sqflite_sqlcipher`](https://pub.dev/packages/sqflite_sqlcipher) or similar |
| Temporary files | App cache directory | Purge on logout; do not store sensitive data in temp |

---

## 5. Network Security

### 5.1 HTTPS Only

- **All network communication** between the app and Supabase (or any other backend) **must** use HTTPS (TLS 1.2+).
- Supabase enforces HTTPS on all endpoints by default.
- **Certificate Pinning (optional but recommended):** For high-security deployments, pin the Supabase API certificate in the Flutter HTTP client to prevent MITM attacks.
- **No HTTP fallback:** The app must never fall back to unencrypted HTTP. On Android, enforce this via `android:usesCleartextTraffic="false"` in `AndroidManifest.xml`.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="false"
    ... >
```

### 5.2 Rate Limiting

| Layer | Implementation |
|---|---|
| **Supabase (built-in)** | Supabase applies default rate limits on Auth endpoints (e.g., login, signup, password reset). |
| **Edge Functions** | Implement custom rate limiting per user/IP using in-memory counters or a Redis/KV store for sensitive operations (e.g., AI API calls). |
| **Client-side** | Debounce rapid-fire requests (e.g., search, button presses) to avoid unnecessary load and accidental abuse. |

---

## 6. App-Blocking Ethics

LET'S FLY TGR includes an **app-blocking / focus mode** feature designed to help users manage their screen time. This feature is built on a strict ethical foundation.

### 6.1 Core Principles

> [!IMPORTANT]
> The app-blocking feature exists to **empower** users, not to surveil or control them.

| Principle | Commitment |
|---|---|
| **Transparent opt-in** | App blocking is **never** enabled by default. Users must explicitly choose to activate it and select which apps to block. |
| **User-controlled** | Users have full control over blocked apps, schedules, and strictness levels at all times. No external party (admin, parent, etc.) can silently configure blocking without the user's knowledge and consent. |
| **No stealth monitoring** | The app does **not** secretly log which apps the user opens, how long they use them, or transmit usage data to any server without explicit consent. |
| **No credential collection** | The app never requests, stores, or transmits the user's device unlock PIN, password, biometric data, or OS-level credentials. |
| **No kernel-level interference** | The app does **not** install kernel modules, root-level daemons, device management profiles (MDM), or any component that operates below the application sandbox. All blocking is implemented via standard, documented OS APIs (e.g., Android `UsageStatsManager`, `AccessibilityService` with explicit user grant). |
| **Emergency exit always available** | Users can **always** disable blocking immediately — there is no "unbreakable" mode that locks the user out of their own device. A clear, accessible exit mechanism is always present. |

### 6.2 Technical Boundaries

```
┌─────────────────────────────────────────────────┐
│                 ALLOWED                          │
│  • UsageStatsManager (Android)                   │
│  • Screen Time API (iOS, if applicable)          │
│  • Accessibility Service (with explicit grant)   │
│  • Local notifications / reminders               │
│  • App overlay prompts (user-dismissable)         │
├─────────────────────────────────────────────────┤
│                 FORBIDDEN                        │
│  • Device admin / MDM enrollment                 │
│  • Root / jailbreak detection for enforcement    │
│  • Kernel modules or system-level hooks          │
│  • VPN-based traffic interception for blocking   │
│  • Uninstall prevention or protection            │
│  • Disabling device settings or notifications    │
└─────────────────────────────────────────────────┘
```

### 6.3 Accessibility Service Transparency

If the app uses Android's `AccessibilityService`:
- The user is shown a **plain-language explanation** of exactly what the service does and why.
- The service is used **only** for detecting foreground app changes, never for reading screen content, capturing keystrokes, or performing actions on behalf of the user.
- The service can be revoked at any time from Android Settings, and the app must handle this gracefully.

---

## 7. Privacy

### 7.1 Data Minimization

- Collect **only** the data strictly necessary for the app's core functionality.
- Do not collect device identifiers, contacts, call logs, SMS, location, or any sensor data unless explicitly required by a user-activated feature and disclosed in the privacy policy.
- Analytics (if any) must be **anonymized** and **aggregated** — no personally identifiable information (PII) in analytics events.

### 7.2 Data Export

- Users can request a full export of their data in a machine-readable format (JSON/CSV) via the app's settings or by contacting the support team.
- Export includes: profile data, focus session history, blocked app lists, and any other user-generated content.

### 7.3 Data Deletion

- Users can delete their account and all associated data at any time from the app's settings.
- Deletion triggers:
  1. `supabase.auth.admin.deleteUser(uid)` — removes the auth record.
  2. Cascading deletes on all tables where `user_id` references the deleted user (enforced via `ON DELETE CASCADE` foreign keys).
  3. Removal of any data in Supabase Storage buckets belonging to the user.
- Deletion is **permanent and irreversible**. A confirmation dialog with explicit user action is required.
- Deletion completes within **30 days** to allow for backup propagation cleanup.

### 7.4 GDPR Compliance

| GDPR Right | Implementation |
|---|---|
| Right to access | Data export feature (Section 7.2) |
| Right to rectification | Users can edit their profile and data in-app |
| Right to erasure | Account deletion feature (Section 7.3) |
| Right to data portability | JSON/CSV export |
| Right to restrict processing | Users can disable features that process their data |
| Right to object | Users can opt out of analytics and non-essential data processing |
| Lawful basis | Consent (explicit opt-in for each data processing activity) |

---

## 8. Credential Configuration Guide

### 8.1 Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com).
2. Navigate to **Settings → API** to find your keys.
3. Copy the following into your `.env` file:

```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6...   # Safe for client
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6...  # Server-side ONLY
```

### 8.2 Google OAuth

1. Go to [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials).
2. Create an **OAuth 2.0 Client ID** for your platform (Android, iOS, Web).
3. Configure the redirect URL in Supabase: **Authentication → Providers → Google**.
4. Add to `.env`:

```env
GOOGLE_CLIENT_ID=<your-google-client-id>.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=<your-google-client-secret>  # Server-side ONLY (Edge Functions)
```

5. In the Flutter app, use only the `GOOGLE_CLIENT_ID` (no client secret on the client side).

### 8.3 Notion API

1. Create an integration at [Notion Developers](https://developers.notion.com/).
2. Copy the **Internal Integration Token**.
3. Add to `.env`:

```env
NOTION_API_KEY=secret_...
NOTION_DATABASE_ID=<your-database-id>  # Optional: for specific database operations
```

4. **This key must only be used in Edge Functions**, never in the Flutter client.

### 8.4 AI API Key

1. Obtain an API key from your AI provider (e.g., Google AI / Gemini, OpenAI, etc.).
2. Add to `.env`:

```env
AI_API_KEY=<your-ai-api-key>
AI_MODEL=<model-name>  # e.g., gemini-2.0-flash
```

3. **This key must only be used in Edge Functions.** The Flutter client calls the Edge Function, which calls the AI API.

### 8.5 `.env.example` Template

Commit this file to the repository as a reference. It contains **no real values**.

```env
# =============================================================================
# LET'S FLY TGR — Environment Variables Template
# =============================================================================
# Copy this file to .env and fill in your values.
# NEVER commit .env to version control.
# =============================================================================

# --- Supabase ---
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here   # ⚠️ Server-side ONLY

# --- Google OAuth ---
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret         # ⚠️ Server-side ONLY

# --- Notion ---
NOTION_API_KEY=secret_your-notion-api-key              # ⚠️ Server-side ONLY
NOTION_DATABASE_ID=your-notion-database-id

# --- AI Provider ---
AI_API_KEY=your-ai-api-key                             # ⚠️ Server-side ONLY
AI_MODEL=gemini-2.0-flash

# --- App Configuration ---
APP_ENV=development                                    # development | staging | production
```

### 8.6 `.gitignore` Requirements

Ensure the following entries exist in your `.gitignore`:

```gitignore
# Environment variables
.env
.env.local
.env.production
.env.staging

# Platform-specific secrets
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
ios/Runner/Info.plist  # If it contains secrets

# IDE / Editor
.idea/
.vscode/
*.iml
```

---

## 9. Security Checklist for Releases

Before every release (including beta and production), the following checklist **must** be completed and signed off.

### Pre-Release Security Checklist

- [ ] **RLS Audit:** Run the RLS audit query (Section 3.3). Result must be empty.
- [ ] **No secrets in code:** Run `git log --all -p | grep -iE "(service_role|secret|password|api_key)"` and verify no real secrets are present.
- [ ] **`.env` not committed:** Verify `.env` is in `.gitignore` and not tracked.
- [ ] **Dependencies updated:** Run `flutter pub outdated` and update packages with known vulnerabilities.
- [ ] **Dependency audit:** Review new dependencies for known CVEs (check [pub.dev advisories](https://pub.dev) and [OSV](https://osv.dev)).
- [ ] **HTTPS enforced:** Confirm `android:usesCleartextTraffic="false"` and no HTTP URLs in code.
- [ ] **Token storage:** Verify all tokens use `flutter_secure_storage`, not `SharedPreferences`.
- [ ] **Input validation:** Confirm server-side validation exists for all user inputs (Edge Functions + DB constraints).
- [ ] **Service role key isolation:** Confirm `SUPABASE_SERVICE_ROLE_KEY` is used only in Edge Functions, not in client code.
- [ ] **App-blocking ethics:** Confirm blocking feature has an accessible emergency exit and no forbidden techniques (Section 6).
- [ ] **Privacy policy updated:** Ensure the privacy policy reflects current data collection and processing practices.
- [ ] **Data deletion tested:** Verify that the account deletion flow removes all user data.
- [ ] **Build signing:** Release APK/AAB is signed with the production keystore. iOS build is signed with the distribution certificate.
- [ ] **ProGuard / R8 (Android):** Obfuscation is enabled for release builds.
- [ ] **No debug flags:** Confirm `kDebugMode` guards are in place, no debug endpoints exposed, no verbose logging in release.

---

## 10. Vulnerability Reporting

### 10.1 Reporting a Vulnerability

If you discover a security vulnerability in LET'S FLY TGR, **please report it responsibly.**

> [!WARNING]
> **Do NOT open a public GitHub issue for security vulnerabilities.** Public disclosure before a fix is available puts users at risk.

**How to report:**

1. **Email:** Send a detailed report to **[security@letsflyTGR.example.com]** (replace with actual contact).
2. **Subject line:** `[SECURITY] Brief description of the vulnerability`
3. **Include:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if any)
   - Your contact information (for follow-up)

### 10.2 Response Timeline

| Stage | Timeline |
|---|---|
| Acknowledgment | Within **48 hours** of report |
| Initial assessment | Within **5 business days** |
| Fix development | Depends on severity (Critical: 72 hours, High: 1 week, Medium: 2 weeks, Low: next release) |
| Disclosure | Coordinated with reporter after fix is deployed |

### 10.3 Severity Classification

| Severity | Description | Example |
|---|---|---|
| **Critical** | Active exploitation possible, data breach risk | RLS bypass, leaked `service_role` key, auth bypass |
| **High** | Significant security impact, exploitation requires some conditions | Stored XSS, privilege escalation, token leakage |
| **Medium** | Limited impact or requires significant user interaction | CSRF, information disclosure of non-sensitive data |
| **Low** | Minimal impact, defense-in-depth improvement | Missing security headers, verbose error messages |

### 10.4 Safe Harbor

We will not pursue legal action against researchers who:
- Report vulnerabilities responsibly following this process.
- Do not access, modify, or delete other users' data.
- Do not publicly disclose the vulnerability before a fix is available.
- Make a good-faith effort to avoid disrupting the service.

---

## License

This security policy is part of the LET'S FLY TGR project. It is subject to the same license as the main project.

---

*Thank you for helping keep LET'S FLY TGR and its users safe.* 🛡️
