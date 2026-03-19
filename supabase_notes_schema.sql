-- Tạo bảng notes (Tham chiếu đến user_books thay vì books như cấu trúc bạn vừa gửi)
CREATE TABLE notes (
  id UUID PRIMARY KEY,
  user_book_id UUID REFERENCES user_books(id) ON DELETE CASCADE,
  page_number INT4,
  content TEXT NOT NULL,
  image_url TEXT,
  is_key_takeaway BOOL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Bật RLS
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Tạo policy cho phép user thao tác với ghi chú của chính họ (Dựa vào user_id trong bảng user_books)
CREATE POLICY "Users can manage their own notes via user_books" ON notes
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_books 
      WHERE user_books.id = notes.user_book_id 
      AND user_books.user_id = auth.uid()
    )
  );
