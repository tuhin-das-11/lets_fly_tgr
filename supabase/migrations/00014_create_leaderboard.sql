-- ==============================================================================
-- Migration: 00014_create_leaderboard.sql
-- Description: Materialized study leaderboard cache, views, and rank recalculation function
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.leaderboard_cache (
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    period_type TEXT NOT NULL CHECK (period_type IN ('daily', 'weekly', 'monthly', 'all_time')),
    period_key TEXT NOT NULL, -- e.g. '2026-11-21' or '2026-W47' or '2026-11'
    total_study_seconds BIGINT NOT NULL DEFAULT 0,
    rank_position INTEGER,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (user_id, period_type, period_key)
);

ALTER TABLE public.leaderboard_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leaderboard cache is public to authenticated users"
    ON public.leaderboard_cache FOR SELECT
    TO authenticated
    USING (true);

-- Function to refresh daily leaderboard positions
CREATE OR REPLACE FUNCTION public.refresh_daily_leaderboard(target_date DATE DEFAULT CURRENT_DATE)
RETURNS VOID AS $$
DECLARE
    date_str TEXT := target_date::TEXT;
BEGIN
    INSERT INTO public.leaderboard_cache (user_id, period_type, period_key, total_study_seconds, rank_position, updated_at)
    SELECT 
        s.user_id,
        'daily',
        date_str,
        COALESCE(SUM(s.duration_seconds), 0) AS total_study_seconds,
        ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(s.duration_seconds), 0) DESC)::INTEGER AS rank_position,
        NOW()
    FROM public.study_sessions s
    WHERE s.started_at::DATE = target_date AND s.is_verified = TRUE
    GROUP BY s.user_id
    ON CONFLICT (user_id, period_type, period_key) DO UPDATE SET
        total_study_seconds = EXCLUDED.total_study_seconds,
        rank_position = EXCLUDED.rank_position,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE INDEX IF NOT EXISTS idx_leaderboard_query ON public.leaderboard_cache(period_type, period_key, rank_position ASC);
