-- ==============================================================================
-- Migration: 00013_create_integrations.sql
-- Description: Notion OAuth tokens, notebook mapping, and AI quota tracking
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.connected_integrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    provider TEXT NOT NULL CHECK (provider IN ('notion', 'google_drive')),
    encrypted_access_token TEXT NOT NULL,
    workspace_id TEXT,
    workspace_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_user_provider UNIQUE (user_id, provider)
);

CREATE TABLE IF NOT EXISTS public.ai_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    feature TEXT NOT NULL CHECK (feature IN ('summarize', 'quiz_gen', 'concept_explainer', 'study_plan')),
    prompt_tokens INTEGER DEFAULT 0 NOT NULL,
    completion_tokens INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.connected_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own integrations"
    ON public.connected_integrations FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own AI usage"
    ON public.ai_usage FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "System/Users can insert AI usage logs"
    ON public.ai_usage FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_ai_usage_user_date ON public.ai_usage(user_id, created_at DESC);
