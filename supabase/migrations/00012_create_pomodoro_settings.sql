-- ==============================================================================
-- Migration: 00012_create_pomodoro_settings.sql
-- Description: Per-user Pomodoro intervals, presets, and sound configurations
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.pomodoro_settings (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    preset_name TEXT DEFAULT 'classic' CHECK (preset_name IN ('classic', 'extended', 'deep_work', 'custom')),
    focus_duration_minutes INTEGER DEFAULT 25 CHECK (focus_duration_minutes BETWEEN 1 AND 180),
    short_break_minutes INTEGER DEFAULT 5 CHECK (short_break_minutes BETWEEN 1 AND 60),
    long_break_minutes INTEGER DEFAULT 15 CHECK (long_break_minutes BETWEEN 1 AND 120),
    long_break_interval INTEGER DEFAULT 4 CHECK (long_break_interval BETWEEN 1 AND 10),
    auto_start_breaks BOOLEAN DEFAULT FALSE NOT NULL,
    auto_start_pomodoros BOOLEAN DEFAULT FALSE NOT NULL,
    sound_alert TEXT DEFAULT 'bell_chime',
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.pomodoro_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own pomodoro settings"
    ON public.pomodoro_settings FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
