-- ==============================================================================
-- Migration: 00002_create_subjects.sql
-- Description: Custom study subjects with categories, colors, icons, and targets
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT NOT NULL DEFAULT '#4F46E5', -- Hex color string e.g. #4F46E5
    icon TEXT NOT NULL DEFAULT 'book',    -- Material icon identifier
    category TEXT DEFAULT 'General',
    target_minutes_daily INTEGER DEFAULT 60 CHECK (target_minutes_daily >= 0),
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_archived BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_user_subject_name UNIQUE (user_id, name)
);

ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view only their own subjects"
    ON public.subjects FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own subjects"
    ON public.subjects FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own subjects"
    ON public.subjects FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own subjects"
    ON public.subjects FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

DROP TRIGGER IF EXISTS trigger_subjects_updated_at ON public.subjects;
CREATE TRIGGER trigger_subjects_updated_at
    BEFORE UPDATE ON public.subjects
    FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE INDEX IF NOT EXISTS idx_subjects_user_id ON public.subjects(user_id);
CREATE INDEX IF NOT EXISTS idx_subjects_sort_order ON public.subjects(user_id, sort_order ASC);
