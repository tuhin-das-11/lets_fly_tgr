-- ==============================================================================
-- Migration: 00008_create_achievements.sql
-- Description: Badges, milestone catalog, user unlocks, and seed data
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.achievements (
    id TEXT PRIMARY KEY, -- e.g. 'first_flight', 'streak_7', 'century_club'
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('streak', 'time', 'social', 'focus')),
    requirement_value INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (user_id, achievement_id)
);

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Achievements catalog readable by all authenticated"
    ON public.achievements FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "User achievements readable by all authenticated"
    ON public.user_achievements FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can record unlocked achievements"
    ON public.user_achievements FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Seed initial achievement badges
INSERT INTO public.achievements (id, title, description, icon, category, requirement_value)
VALUES
    ('first_hour', 'First Flight', 'Complete your very first 60 minutes of deep study.', 'flight_takeoff', 'time', 3600),
    ('streak_3', 'Momentum Builder', 'Maintain an active study streak for 3 consecutive days.', 'local_fire_department', 'streak', 3),
    ('streak_7', 'Habit Former', 'Maintain a study streak for 7 consecutive days.', 'bolt', 'streak', 7),
    ('streak_30', 'Iron Will', 'Study every day for a full calendar month (30 days).', 'military_tech', 'streak', 30),
    ('marathon_4h', 'Deep Diver', 'Complete a single uninterrupted 4-hour study session.', 'timer', 'focus', 14400),
    ('night_owl', 'Midnight Oil', 'Log at least 2 hours of study between 12:00 AM and 4:00 AM.', 'bedtime', 'focus', 7200),
    ('early_bird', 'Dawn Patrol', 'Begin and log a study session before 6:00 AM.', 'wb_sunny', 'focus', 1),
    ('century_hours', 'Century Club', 'Accumulate 100 lifetime hours of verified study.', 'workspace_premium', 'time', 360000),
    ('social_flyer', 'Flock Member', 'Join your first study group.', 'groups', 'social', 1),
    ('room_champion', 'Room Leader', 'Finish #1 on your study group daily leaderboard.', 'emoji_events', 'social', 1)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description;
