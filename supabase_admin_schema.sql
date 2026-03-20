-- ============================================================
-- ADMIN SCHEMA cho Reading Station App
-- Chạy file này trong SQL Editor SAU KHI đã chạy các file schema trước
-- ============================================================

-- 1. Thêm cột 'role' vào bảng users hiện tại
ALTER TABLE users ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin'));

-- 2. BẢNG REPORTS - Quản lý Báo cáo (FR5.2) để Admin xử lý vi phạm
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  activity_id UUID REFERENCES activities(id) ON DELETE CASCADE, -- Bài đăng vi phạm (nếu có)
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE, -- Ghi chú vi phạm (nếu có)
  reason TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'resolved', 'dismissed')),
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Phân quyền cho Bảng Reports (Row Level Security)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- 2.1. Người dùng bình thường chỉ được phép TẠO báo cáo (insert)
CREATE POLICY "Users can create reports" ON reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);

-- 2.2. Admin được quyền XEM toàn bộ các báo cáo
CREATE POLICY "Admins can view all reports" ON reports
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'admin')
  );

-- 2.3. Admin được quyền CẬP NHẬT (đánh dấu đã xử lý) các báo cáo
CREATE POLICY "Admins can update reports" ON reports
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'admin')
  );

-- 3. VIEW THỐNG KÊ (SYSTEM_METRICS) (FR5.4)
-- Thay vì Admin đếm từng bảng (tốn thời gian server), tính năng View sẽ thống kê luôn
CREATE OR REPLACE VIEW system_metrics AS
SELECT
  (SELECT COUNT(*) FROM users) AS total_users,
  (SELECT COUNT(*) FROM books) AS total_master_books,
  (SELECT COUNT(*) FROM flashcards) AS total_flashcards,
  (SELECT COUNT(*) FROM activities) AS total_activities,
  (SELECT COUNT(*) FROM reports WHERE status = 'pending') AS pending_reports;
