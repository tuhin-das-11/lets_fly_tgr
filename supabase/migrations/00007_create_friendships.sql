-- ==============================================================================
-- Migration: 00007_create_friendships.sql
-- Description: Peer social graph, friend requests, and study visibility
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_friendship_pair UNIQUE (user_id, friend_id),
    CONSTRAINT prevent_self_friendship CHECK (user_id != friend_id)
);

ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view friendships involving them"
    ON public.friendships FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can send friend requests"
    ON public.friendships FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Recipients can accept/reject friend requests"
    ON public.friendships FOR UPDATE
    TO authenticated
    USING (auth.uid() = friend_id OR auth.uid() = user_id)
    WITH CHECK (auth.uid() = friend_id OR auth.uid() = user_id);

CREATE POLICY "Users can remove friendships"
    ON public.friendships FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE INDEX IF NOT EXISTS idx_friendships_user_id ON public.friendships(user_id, status);
CREATE INDEX IF NOT EXISTS idx_friendships_friend_id ON public.friendships(friend_id, status);
