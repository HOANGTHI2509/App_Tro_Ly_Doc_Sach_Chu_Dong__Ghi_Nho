# Ánh xạ Tính năng Giữa Admin và Người dùng (Symmetry Features)

Dựa trên các chức năng dành cho Admin (FR5.1 - FR5.4) và giao diện hỗ trợ/cài đặt của người dùng trong ảnh, dưới đây là sự đối xứng và mối liên hệ giữa hai bên hệ thống:

## 1. Kiểm duyệt Nội dung & Xử lý Vi phạm (Content Moderation)
Theo **FR5.2 (Admin)** và **mục "Góp ý & Báo lỗi" (User)**:

*   **Phía Người dùng (User Cung cấp/Báo cáo):**
    *   Sử dụng tính năng **"Báo cáo sự cố"** để gửi phản hồi khi gặp nội dung không phù hợp hoặc lỗi app.
    *   (Tính năng đi kèm) Nút **"Báo cáo" (Report Flag)** ghim trực tiếp trên các Ghi chú (Note), Đánh giá (Review) hoặc Bình luận của người dùng khác trên nền tảng (Bảng tin/Community).
*   **Phía Quản trị (Admin Xử lý - FR5.2):**
    *   Tiếp nhận các ticket (phiếu) từ "Báo cáo sự cố" và các "Cờ báo cáo" từ người dùng.
    *   Xem xét nội dung bị báo cáo (văn bản độc hại, spam, xuyên tạc).
    *   **Thực thi:** Có quyền Ẩn/Xóa trực tiếp nội dung vi phạm trên Bảng tin (Feed), gỡ bỏ Ghi chú (Note).

## 2. Dịch vụ Khách hàng & Hỗ trợ (Customer Support)
Từ **mục "Liên hệ hỗ trợ" (User)**:

*   **Phía Người dùng (User Yêu cầu):**
    *   **"Gửi email hỗ trợ"**: Cho phép user gửi mail trực tiếp đến `hotro@tramdoc.com`.
    *   **"Chat với đội ngũ"**: Mở kênh liên lạc trực tiếp (Live chat) với hứa hẹn phản hồi trong 24h.
*   **Phía Quản trị (Admin Phục vụ - Mở rộng từ mô tả ban đầu):**
    *   **Hệ thống Ticket Hỗ trợ**: Tích hợp hòm thư để admin nhận, phân công và phản hồi các email từ người dùng.
    *   **Giao diện Chat**: Công cụ cho Admin/Nhân viên CSKH trả lời tin nhắn trực tiếp từ chức năng "Chat với đội ngũ" của người dùng.

## 3. Lắng nghe Góp ý & Cải tiến Sản phẩm (Product Feedback)
Từ **mục "Góp ý & Báo lỗi" (User)**:

*   **Phía Người dùng (User Đóng góp):**
    *   **"Góp ý tính năng mới"**: Nơi user có thể soạn thảo, đề xuất các ý tưởng, tính năng họ mong muốn có trong tương lai.
*   **Phía Quản trị (Admin Đánh giá - Mở rộng):**
    *   Màn hình danh sách các "Góp ý tính năng mới" từ cộng đồng.
    *   Công cụ duyệt, gắn nhãn (Tag) trạng thái (VD: "Đang xem xét", "Đã đưa vào lộ trình", "Từ chối") và thống kê những yêu cầu phổ biến nhất.

## 4. Sự đối xứng trong Quản lý Dữ liệu Hệ thống (Gián tiếp)
Liên quan đến **FR5.1, FR5.3, và FR5.4**:

*   **Tài khoản (FR5.3) & Kỷ luật:**
    *   **User**: Tạo tài khoản (đăng ký), quản lý hồ sơ cá nhân và hoạt động trong cộng đồng.
    *   **Admin**: Quản lý danh sách (Search, view status). Dùng quyền **Khóa (Ban) tạm thời/vĩnh viễn** dựa trên kết quả từ việc [xử lý báo cáo ở FR5.2].
*   **Dữ liệu Sách / Book Master Data (FR5.1):**
    *   **User**: Nhập API/Scan mã vạch để thêm sách mới vào tủ sách của bản thân.
    *   **Admin**: "Người gác cổng" dữ liệu. Chuẩn hóa Metadata, kiểm tra thông tin do API kéo về/người dùng nhập có sai lệch không để chỉnh sửa (Ảnh bìa, Tác giả, Nhà xuất bản). Đảm bảo data sách chung của hệ thống luôn sạch và chính xác.
*   **Chỉ số & Hiệu suất / Dashboard (FR5.4):**
    *   **User**: Hoạt động trên app (truy cập, đọc sách, tạo flashcard).
    *   **Admin**: Sử dụng số liệu tổng hợp (DAU, số sách thêm mới, lượng Flashcard) sinh ra từ user để đánh giá, theo dõi bằng biểu đồ, đảm bảo app duy trì sức hút và kiểm soát chi phí hạ tầng.
