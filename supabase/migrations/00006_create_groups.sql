-- ==============================================================================
-- Migration: 00006_create_groups.sql
-- Description: Study groups, membership roles, and 6-char invitation codes
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    avatar_url TEXT,
    is_private BOOLEAN DEFAULT FALSE NOT NULL,
    invite_code VARCHAR(8) UNIQUE NOT NULL,
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    max_members INTEGER DEFAULT 50 CHECK (max_members BETWEEN 2 AND 500),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.group_members (
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
    joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (group_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.group_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    inviter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    invitee_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT unique_group_invite UNIQUE (group_id, invitee_id)
);

ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_invitations ENABLE ROW LEVEL SECURITY;

-- Group RLS
CREATE POLICY "Public groups are viewable by anyone, private by members"
    ON public.groups FOR SELECT
    TO authenticated
    USING (
        NOT is_private OR 
        EXISTS (
            SELECT 1 FROM public.group_members 
            WHERE group_members.group_id = groups.id AND group_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Authenticated users can create groups"
    ON public.groups FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Group owners can update their groups"
    ON public.groups FOR UPDATE
    TO authenticated
    USING (auth.uid() = owner_id)
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Group owners can delete their groups"
    ON public.groups FOR DELETE
    TO authenticated
    USING (auth.uid() = owner_id);

-- Group Members RLS
CREATE POLICY "Members can view membership of their groups"
    ON public.group_members FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.group_members AS m
            WHERE m.group_id = group_members.group_id AND m.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join groups"
    ON public.group_members FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave or admins can remove members"
    ON public.group_members FOR DELETE
    TO authenticated
    USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM public.groups
            WHERE groups.id = group_members.group_id AND groups.owner_id = auth.uid()
        )
    );

-- Trigger: Automatically add owner as group_member upon creation
CREATE OR REPLACE FUNCTION public.handle_group_created()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.group_members (group_id, user_id, role)
    VALUES (NEW.id, NEW.owner_id, 'owner');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_group_created ON public.groups;
CREATE TRIGGER on_group_created
    AFTER INSERT ON public.groups
    FOR EACH ROW EXECUTE FUNCTION public.handle_group_created();

CREATE INDEX IF NOT EXISTS idx_group_members_user ON public.group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_groups_invite_code ON public.groups(invite_code);
