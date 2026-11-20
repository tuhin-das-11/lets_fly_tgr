-- ==============================================================================
-- Migration: 00011_create_app_blocking.sql
-- Description: App blocking configurations, blocklists, and scheduled focus sessions
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.app_blocking_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    package_name TEXT NOT NULL, -- e.g. 'com.instagram.android' or 'chrome.exe'
    app_display_name TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'windows')),
    is_blocked_during_study BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_user_package_platform UNIQUE (user_id, package_name, platform)
);

CREATE TABLE IF NOT EXISTS public.focus_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7), -- 1=Monday, 7=Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT check_schedule_times CHECK (end_time > start_time)
);

ALTER TABLE public.app_blocking_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.focus_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own blocking rules"
    ON public.app_blocking_rules FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage their own focus schedules"
    ON public.focus_schedules FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_blocking_rules_user ON public.app_blocking_rules(user_id, platform);
