-- ============================================================
-- CẬP NHẬT SCHEMA: Thêm bảng Flashcards, Friendships, Activities
-- Chạy file này trong SQL Editor SAU KHI đã chạy supabase_full_schema.sql
-- ============================================================

-- 1. Thêm cột tag vào bảng notes
ALTER TABLE notes ADD COLUMN IF NOT EXISTS tag TEXT;

-- 2. BẢNG FLASHCARDS - Thẻ ôn tập Spaced Repetition
CREATE TABLE IF NOT EXISTS flashcards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  ease_factor FLOAT DEFAULT 2.5,
  interval_days INT DEFAULT 0,
  repetitions INT DEFAULT 0,
  next_review_date TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  last_reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own flashcards" ON flashcards
  FOR ALL USING (auth.uid() = user_id);

-- 3. BẢNG FRIENDSHIPS - Kết bạn
CREATE TABLE IF NOT EXISTS friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(user_id, friend_id)
);

ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own friendships" ON friendships
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can send friend requests" ON friendships
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update friendship status" ON friendships
  FOR UPDATE USING (auth.uid() = friend_id OR auth.uid() = user_id);

CREATE POLICY "Users can delete own friendships" ON friendships
  FOR DELETE USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- 4. BẢNG ACTIVITIES - Hoạt động feed
CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('finished_book', 'added_book', 'created_note', 'started_reading')),
  book_title TEXT,
  book_image_url TEXT,
  book_author TEXT,
  rating INT,
  note_content TEXT,
  note_page INT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE activities ENABLE ROW LEVEL SECURITY;

-- Bạn bè có thể xem hoạt động của nhau
CREATE POLICY "Users can view activities from friends" ON activities
  FOR SELECT USING (
    auth.uid() = user_id
    OR EXISTS (
      SELECT 1 FROM friendships
      WHERE status = 'accepted'
      AND (
        (friendships.user_id = auth.uid() AND friendships.friend_id = activities.user_id)
        OR (friendships.friend_id = auth.uid() AND friendships.user_id = activities.user_id)
      )
    )
  );

CREATE POLICY "Users can insert own activities" ON activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);
