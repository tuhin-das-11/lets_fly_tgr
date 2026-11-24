<div align="center">

<!-- PROJECT LOGO -->
<!-- Replace with your actual logo -->
<img src="assets/images/logo.png" alt="LET'S FLY TGR Logo" width="160" height="160">

# ✈️ LET'S FLY TGR

### *Study Together. Focus Better. Fly Higher.*

A cross-platform productivity & study-tracking ecosystem inspired by [Yeolpumta (열품타)](https://yeolpumta.com), built with Flutter.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-blue?style=for-the-badge)](#)

---

[Features](#-features) · [Tech Stack](#-tech-stack) · [Architecture](#-architecture) · [Getting Started](#-getting-started) · [Contributing](#-contributing) · [License](#-license)

</div>

---

## 📖 About

**LET'S FLY TGR** is a feature-rich, cross-platform (Android + Windows) study companion designed to help students and professionals track, optimise, and gamify their learning journey. Inspired by Korea's beloved Yeolpumta (YPT) app, it brings real-time study timers, social accountability through groups & leaderboards, smart analytics, and deep focus tools — all synchronised seamlessly across your devices.

> [!NOTE]
> This project targets **Android** and **Windows** desktop. iOS and macOS support may follow in future releases.

---

## 📸 Screenshots

<!-- Replace these placeholders with actual screenshots -->

<div align="center">

| Home / Dashboard | Study Timer | Leaderboard |
|:---:|:---:|:---:|
| <img src="docs/screenshots/home.png" width="250"> | <img src="docs/screenshots/timer.png" width="250"> | <img src="docs/screenshots/leaderboard.png" width="250"> |

| Analytics | Groups | Settings |
|:---:|:---:|:---:|
| <img src="docs/screenshots/analytics.png" width="250"> | <img src="docs/screenshots/groups.png" width="250"> | <img src="docs/screenshots/settings.png" width="250"> |

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 📚 Core Study Tools
- ⏱️ **Study Timer** — Precision stopwatch & countdown modes
- 🍅 **Pomodoro Timer** — Customisable work/break intervals
- 📖 **Subject Management** — Colour-coded subjects with per-subject stats
- 🔒 **App Blocking** — Block distracting apps during focus sessions *(Android)*

</td>
<td width="50%">

### 📊 Analytics & Insights
- 📈 **Daily / Weekly / Monthly Charts** — Visualise study trends
- 🎯 **Goal Tracking** — Set & monitor daily study-hour targets
- 🏆 **Streaks & Achievements** — Stay motivated with gamification
- 🤖 **AI Study Assistant** — Personalised tips powered by AI

</td>
</tr>
<tr>
<td width="50%">

### 👥 Social & Community
- 🏠 **Study Groups** — Create or join rooms, study with friends
- 🥇 **Leaderboards** — Compete on daily, weekly, and all-time rankings
- 🔔 **Real-time Presence** — See who's studying right now
- 💬 **Group Chat** — In-room messaging during sessions

</td>
<td width="50%">

### 🔗 Integrations & Sync
- ☁️ **Cross-device Sync** — Seamless data sync via Supabase
- 📝 **Notion Integration** — Export study logs to your Notion workspace
- 💾 **Offline Mode** — Local SQLite cache; syncs when back online
- 🖥️ **Windows Desktop** — Native Windows support with system tray

</td>
</tr>
</table>

---

## 🛠️ Tech Stack

<div align="center">

| Layer | Technology |
|:---|:---|
| **Framework** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white) |
| **State Management** | ![Riverpod](https://img.shields.io/badge/Riverpod-00B0FF?style=flat-square&logo=dart&logoColor=white) |
| **Routing** | ![GoRouter](https://img.shields.io/badge/GoRouter-02569B?style=flat-square&logo=flutter&logoColor=white) |
| **Design System** | ![Material 3](https://img.shields.io/badge/Material%203-757575?style=flat-square&logo=materialdesign&logoColor=white) |
| **Backend** | ![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?style=flat-square&logo=supabase&logoColor=white) (PostgreSQL · Auth · Realtime · Storage) |
| **Local Database** | ![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white) |
| **Android Native** | ![Kotlin](https://img.shields.io/badge/Kotlin-7F52FF?style=flat-square&logo=kotlin&logoColor=white) |
| **Windows Native** | ![C#](https://img.shields.io/badge/C%23-239120?style=flat-square&logo=csharp&logoColor=white) |

</div>

---

## 🏗️ Architecture

LET'S FLY TGR follows a **clean architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│         Screens · Widgets · Controllers (Riverpod)      │
├─────────────────────────────────────────────────────────┤
│                    Application Layer                    │
│               Services · Use Cases · DTOs               │
├─────────────────────────────────────────────────────────┤
│                     Domain Layer                        │
│            Entities · Repositories (abstract)           │
├─────────────────────────────────────────────────────────┤
│                  Infrastructure Layer                   │
│     Supabase Client · SQLite · Platform Channels        │
├──────────────────────┬──────────────────────────────────┤
│   Android (Kotlin)   │        Windows (C#)              │
│  App Blocking · FCM  │  System Tray · Native Helpers    │
└──────────────────────┴──────────────────────────────────┘
```

**Key architectural decisions:**

- **Riverpod** for reactive, testable, and compile-safe state management.
- **GoRouter** for declarative, deep-link–aware navigation.
- **Repository pattern** abstracts data sources — swap Supabase ↔ SQLite transparently.
- **Platform channels** bridge Flutter ↔ Kotlin (Android) and Flutter ↔ C# (Windows) for native features.
- **Offline-first**: SQLite caches all data locally; Supabase Realtime syncs when connectivity resumes.

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Version | Link |
|:---|:---|:---|
| **Flutter SDK** | 3.x (stable) | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | 3.x (bundled with Flutter) | — |
| **Android Studio** | Latest | [developer.android.com/studio](https://developer.android.com/studio) |
| **Visual Studio** | 2022+ (with C++ & C# workloads) | [visualstudio.microsoft.com](https://visualstudio.microsoft.com) |
| **Git** | 2.x+ | [git-scm.com](https://git-scm.com) |
| **Supabase Account** | Free tier works | [supabase.com](https://supabase.com) |

> [!IMPORTANT]
> **Flutter must be installed** before you can build this project.
> Follow the official guide at **[flutter.dev](https://flutter.dev)** and ensure `flutter doctor` reports no critical issues for your target platform(s).

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/tuhin-das-11/lets-fly-tgr.git
cd lets-fly-tgr

# 2. Install dependencies
flutter pub get

# 3. Verify your setup
flutter doctor
```

### Environment Configuration

This project uses a `.env` file (via the `flutter_dotenv` package) to manage secrets. **Never commit your `.env` file.**

```bash
# Copy the example file
cp .env.example .env
```

Then fill in your credentials:

```dotenv
# .env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here   # server-side only

# Optional integrations
NOTION_API_KEY=your-notion-api-key
AI_API_KEY=your-ai-api-key
```

> [!TIP]
> You can find your Supabase URL and keys in the **Supabase Dashboard → Settings → API**.

### Run the App

```bash
# Android (emulator or connected device)
flutter run -d android

# Windows desktop
flutter run -d windows
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Windows
flutter build windows --release
```

---

## 📂 Project Structure

```
lets_fly_tgr/
├── android/                    # Android platform (Kotlin)
│   └── app/src/main/kotlin/    # Native Android code (app blocking, etc.)
├── windows/                    # Windows platform (C# helpers)
├── lib/
│   ├── main.dart               # App entry point
│   ├── app/                    # App configuration, routes, theme
│   │   ├── router.dart         # GoRouter config
│   │   └── theme.dart          # Material 3 theme
│   ├── core/                   # Shared utilities, constants, extensions
│   │   ├── constants/
│   │   ├── extensions/
│   │   └── utils/
│   ├── features/               # Feature modules
│   │   ├── auth/               # Authentication (Supabase Auth)
│   │   ├── timer/              # Study & Pomodoro timers
│   │   ├── subjects/           # Subject management
│   │   ├── groups/             # Study groups & chat
│   │   ├── leaderboard/        # Rankings & competitions
│   │   ├── analytics/          # Charts & insights
│   │   ├── app_blocking/       # Distraction blocker (Android)
│   │   ├── notion/             # Notion integration
│   │   └── ai_assistant/       # AI-powered study tips
│   ├── data/                   # Data layer
│   │   ├── models/             # Data models / DTOs
│   │   ├── repositories/       # Repository implementations
│   │   └── sources/            # Supabase & SQLite data sources
│   └── providers/              # Riverpod providers
├── assets/
│   ├── images/                 # App images & logo
│   ├── icons/                  # Custom icons
│   └── fonts/                  # Custom fonts
├── test/                       # Unit & widget tests
├── integration_test/           # Integration tests
├── .env.example                # Environment variable template
├── pubspec.yaml                # Flutter dependencies
└── README.md                   # You are here!
```

---

## 🤝 Contributing

Contributions are what make the open-source community amazing. Any contributions you make are **greatly appreciated**!

### How to Contribute

1. **Fork** the repository
2. **Create** your feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit** your changes with clear messages
   ```bash
   git commit -m "feat: add amazing feature"
   ```
4. **Push** to the branch
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open** a Pull Request

### Guidelines

- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
- Write tests for new features and bug fixes.
- Run `flutter analyze` and `flutter test` before submitting.
- Keep PRs focused — one feature or fix per PR.
- Update documentation as needed.

> [!NOTE]
> Please open an **Issue** first to discuss large changes before investing significant time.

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.

```
MIT License

Copyright (c) 2026 LET'S FLY TGR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📬 Contact

| | |
|:---|:---|
| **Project Lead** | Tuhin Das |
| **Email** | [dastuhin01019@gmail.com](mailto:dastuhin01019@gmail.com) |
| **GitHub** | [@tuhin-das-11](https://github.com/tuhin-das-11) |
| **Project Link** | [github.com/tuhin-das-11/lets-fly-tgr](https://github.com/tuhin-das-11/lets-fly-tgr) |

---

<div align="center">

**Built with ❤️ and ☕ by Tuhin Das using Flutter**

*If this project helps you study better, give it a ⭐!*

[⬆ Back to Top](#️-lets-fly-tgr)

</div>
