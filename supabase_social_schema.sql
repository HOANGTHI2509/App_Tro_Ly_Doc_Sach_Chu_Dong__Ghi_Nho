-- ============================================================
-- BẢNG LIKES & COMMENTS cho Activities
-- Chạy trong Supabase SQL Editor
-- ============================================================

-- 1. Bảng LIKES
CREATE TABLE IF NOT EXISTS activity_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(activity_id, user_id)
);

ALTER TABLE activity_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "likes_select" ON activity_likes
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "likes_insert" ON activity_likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "likes_delete" ON activity_likes
  FOR DELETE USING (auth.uid() = user_id);

-- 2. Bảng COMMENTS
CREATE TABLE IF NOT EXISTS activity_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE activity_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "comments_select" ON activity_comments
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "comments_insert" ON activity_comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "comments_delete" ON activity_comments
  FOR DELETE USING (auth.uid() = user_id);

-- 3. Fix RLS cho activities - cho authenticated user xem tất cả
DROP POLICY IF EXISTS "Users can view activities from friends" ON activities;
DROP POLICY IF EXISTS "activities_select" ON activities;
CREATE POLICY "activities_select" ON activities
  FOR SELECT USING (auth.role() = 'authenticated');
