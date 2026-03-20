# ĐỀ CƯƠNG BÁO CÁO DỰ ÁN CUỐI KỲ
## TÊN ĐỀ TÀI: XÂY DỰNG ỨNG DỤNG TRỢ LÝ ĐỌC SÁCH CHỦ ĐỘNG VÀ GHI NHỚ (TRẠM ĐỌC)

---

**MỤC LỤC / CÁC MỤC CẦN TRIỂN KHAI TRONG BÁO CÁO WORD:**

**CHƯƠNG 1: MỞ ĐẦU**
1.1. Lý do chọn đề tài (Thực trạng đọc sách hiện nay, hiện tượng đọc xong mau quên).
1.2. Mục tiêu nghiên cứu và phát triển (Tạo ra công cụ hỗ trợ đọc, ghi nhớ và kết nối cộng đồng).
1.3. Phạm vi của đề tài (Áp dụng cho người dùng Mobile, nền tảng Android/iOS).
1.4. Đối tượng phục vụ (Người yêu sách, sinh viên, người có nhu cầu học tập/nhắc lại kiến thức).

**CHƯƠNG 2: CƠ SỞ LÝ THUYẾT VÀ CÔNG NGHỆ**
2.1. Phương pháp ghi nhớ chủ động (Spaced Repetition & Flashcard).
2.2. Nền tảng lập trình Flutter và ngôn ngữ Dart.
2.3. Quản lý trạng thái với Riverpod.
2.4. Hệ quản trị cơ sở dữ liệu và Backend-as-a-Service (BaaS) Supabase (PostgreSQL, Auth, Storage).

**CHƯƠNG 3: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG**
3.1. Phân tích yêu cầu chức năng (Người dùng thường, Quản trị viên).
3.2. Sơ đồ Use Case (Các kịch bản sử dụng hệ thống).
3.3. Thiết kế Cơ sở dữ liệu (Database Schema, Sơ đồ ERD chứa: users, books, user_books, notes, flashcards, friendships, activities, reports).
3.4. Cấu trúc an toàn dữ liệu (Row Level Security - RLS).
3.5. Thiết kế Giao diện (UI/UX) - Phong cách Glassmorphism, Luồng màn hình (Thư viện, Ghi chú, Ôn tập, Cá nhân, Admin Dashboard).

**CHƯƠNG 4: XÂY DỰNG VÀ TRIỂN KHAI ỨNG DỤNG**
4.1. Cấu trúc kiến trúc mã nguồn (MVC, Riverpod Architecture).
4.2. Khối chức năng Frontend cho User (Chức năng đọc sách, quét mã/tìm sách, tạo ghi chú, ôn tập thẻ bài, mạng xã hội chia sẻ).
4.3. Phân luồng bảo mật (AuthWrapper) và Cơ chế xác thực.
4.4. Khối chức năng cho Admin (Dashboard thống kê biểu đồ động, Phê duyệt sách, Khóa/Mở tài khoản, Xử lý báo cáo vi phạm).

**CHƯƠNG 5: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN TIẾP THEO**
5.1. Kết quả đạt được (Chức năng hoàn thiện, hệ thống hoạt động thực tế ổn định).
5.2. Hạn chế của ứng dụng (Phụ thuộc vào dữ liệu tự nhập, chưa tự động hóa hoàn toàn).
5.3. Định hướng phát triển tương lai (Tích hợp AI OCR quét văn bản sách, Phân tích dữ liệu học quét theo sở thích, Gamification - Bảng xếp hạng).

**DANH MỤC TÀI LIỆU THAM KHẢO**
