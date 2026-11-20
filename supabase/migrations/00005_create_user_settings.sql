-- ==============================================================================
-- Migration: 00005_create_user_settings.sql
-- Description: Per-user preferences (theme, privacy, notifications, daily targets)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    theme_mode TEXT DEFAULT 'system' CHECK (theme_mode IN ('system', 'light', 'dark')),
    daily_target_minutes INTEGER DEFAULT 240 CHECK (daily_target_minutes >= 0),
    sound_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    vibration_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    keep_screen_on BOOLEAN DEFAULT TRUE NOT NULL,
    strict_focus_mode BOOLEAN DEFAULT FALSE NOT NULL,
    allow_break_interrupts BOOLEAN DEFAULT TRUE NOT NULL,
    break_duration_minutes INTEGER DEFAULT 10,
    notification_daily_reminder BOOLEAN DEFAULT TRUE NOT NULL,
    reminder_time_hour INTEGER DEFAULT 9 CHECK (reminder_time_hour BETWEEN 0 AND 23),
    reminder_time_minute INTEGER DEFAULT 0 CHECK (reminder_time_minute BETWEEN 0 AND 59),
    notification_friends_activity BOOLEAN DEFAULT TRUE NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own settings"
    ON public.user_settings FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Auto-provision user_settings on user creation
CREATE OR REPLACE FUNCTION public.handle_new_user_settings()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created_settings ON auth.users;
CREATE TRIGGER on_auth_user_created_settings
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_settings();
