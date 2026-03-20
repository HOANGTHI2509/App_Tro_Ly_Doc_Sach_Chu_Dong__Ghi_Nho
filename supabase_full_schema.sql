-- ============================================================
-- FULL SCHEMA cho Reading Station App (Supabase mới)
-- Chạy toàn bộ file này trong SQL Editor của Supabase
-- ============================================================

-- 1. BẢNG USERS - Lưu thông tin người dùng
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);


-- 2. BẢNG BOOKS - Lưu thông tin sách (chia sẻ giữa các user)
CREATE TABLE books (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  authors TEXT[] DEFAULT '{}',
  description TEXT,
  cover_image_url TEXT,
  page_count INT4,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- Ai đăng nhập đều đọc được sách
CREATE POLICY "Authenticated users can view books" ON books
  FOR SELECT USING (auth.role() = 'authenticated');

-- Ai đăng nhập đều thêm/cập nhật được sách
CREATE POLICY "Authenticated users can insert books" ON books
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update books" ON books
  FOR UPDATE USING (auth.role() = 'authenticated');


-- 3. BẢNG USER_BOOKS - Sách của từng user (tủ sách cá nhân)
CREATE TABLE user_books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id TEXT REFERENCES books(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  authors TEXT[] DEFAULT '{}',
  image_url TEXT,
  custom_cover_url TEXT,
  page_count INT4,
  categories TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'Want to read' CHECK (status IN ('Want to read', 'Reading', 'Completed')),
  current_page INT4 DEFAULT 0,
  rating INT4,
  notes TEXT,
  date_added TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  date_completed TIMESTAMPTZ
);

ALTER TABLE user_books ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own books" ON user_books
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own books" ON user_books
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own books" ON user_books
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own books" ON user_books
  FOR DELETE USING (auth.uid() = user_id);


-- 4. BẢNG NOTES - Ghi chú cho từng sách
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_book_id UUID REFERENCES user_books(id) ON DELETE CASCADE,
  page_number INT4,
  content TEXT NOT NULL,
  image_url TEXT,
  is_key_takeaway BOOL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own notes" ON notes
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_books 
      WHERE user_books.id = notes.user_book_id 
      AND user_books.user_id = auth.uid()
    )
  );


-- 5. TẠO STORAGE BUCKET cho ảnh bìa sách
INSERT INTO storage.buckets (id, name, public) 
VALUES ('covers', 'covers', true);

-- Policy cho storage: user được upload ảnh
CREATE POLICY "Authenticated users can upload covers" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'covers' AND auth.role() = 'authenticated'
  );

-- Policy cho storage: ai cũng xem được ảnh (public bucket)
CREATE POLICY "Public can view covers" ON storage.objects
  FOR SELECT USING (bucket_id = 'covers');

-- Policy cho storage: user được xóa ảnh của mình
CREATE POLICY "Users can delete own covers" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'covers' AND auth.uid()::text = (storage.foldername(name))[1]
  );
