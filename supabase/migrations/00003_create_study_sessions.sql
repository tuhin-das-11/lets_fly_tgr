-- ==============================================================================
-- Migration: 00003_create_study_sessions.sql
-- Description: Completed study sessions and cross-device active server sessions
-- ==============================================================================

-- Completed study sessions
CREATE TABLE IF NOT EXISTS public.study_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ NOT NULL,
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds >= 0),
    device_id TEXT NOT NULL,
    session_type TEXT DEFAULT 'stopwatch' CHECK (session_type IN ('stopwatch', 'pomodoro_focus', 'pomodoro_break', 'manual')),
    is_verified BOOLEAN DEFAULT TRUE NOT NULL,
    notes TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT check_session_dates CHECK (ended_at >= started_at)
);

ALTER TABLE public.study_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own study sessions"
    ON public.study_sessions FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own study sessions"
    ON public.study_sessions FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own study sessions"
    ON public.study_sessions FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own study sessions"
    ON public.study_sessions FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Server-Authoritative Active Sessions for Cross-Device Synchronization
CREATE TABLE IF NOT EXISTS public.active_sessions (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'windows', 'web', 'ios', 'macos')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_heartbeat TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'running' CHECK (status IN ('running', 'paused')),
    paused_seconds_total INTEGER NOT NULL DEFAULT 0,
    session_type TEXT NOT NULL DEFAULT 'stopwatch' CHECK (session_type IN ('stopwatch', 'pomodoro')),
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

ALTER TABLE public.active_sessions ENABLE ROW LEVEL SECURITY;

-- Friends and group members can observe active study sessions for live rooms
CREATE POLICY "Active sessions readable by authenticated users"
    ON public.active_sessions FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage only their own active session"
    ON public.active_sessions FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Function to update profile total study time upon session completion
CREATE OR REPLACE FUNCTION public.sync_profile_study_totals()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.profiles
    SET 
        total_study_seconds = total_study_seconds + NEW.duration_seconds,
        last_study_date = CURRENT_DATE
    WHERE id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_sync_study_totals ON public.study_sessions;
CREATE TRIGGER trigger_sync_study_totals
    AFTER INSERT ON public.study_sessions
    FOR EACH ROW EXECUTE FUNCTION public.sync_profile_study_totals();

CREATE INDEX IF NOT EXISTS idx_study_sessions_user_date ON public.study_sessions(user_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_study_sessions_subject ON public.study_sessions(subject_id);
CREATE INDEX IF NOT EXISTS idx_active_sessions_heartbeat ON public.active_sessions(last_heartbeat);
