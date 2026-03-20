DROP TABLE IF EXISTS activity_comments;
DROP TABLE IF EXISTS activity_likes;
DROP TABLE IF EXISTS activities;

CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('finished_book', 'added_book', 'created_note', 'started_reading')),
  book_title TEXT,
  book_image_url TEXT,
  book_author TEXT,
  rating INT,
  note_content TEXT,
  note_page INT,
  likes INT DEFAULT 0,
  comments INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "activities_select" ON activities FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Users can insert own activities" ON activities FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS activity_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(activity_id, user_id)
);

ALTER TABLE activity_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "likes_select" ON activity_likes FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "likes_insert" ON activity_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "likes_delete" ON activity_likes FOR DELETE USING (auth.uid() = user_id);

CREATE TABLE IF NOT EXISTS activity_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE activity_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "comments_select" ON activity_comments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "comments_insert" ON activity_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "comments_delete" ON activity_comments FOR DELETE USING (auth.uid() = user_id);

