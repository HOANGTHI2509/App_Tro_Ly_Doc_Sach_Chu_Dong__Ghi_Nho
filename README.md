# 📚 Trạm Đọc (Reading Station)

> **Trợ lý Đọc sách Chủ động & Ghi nhớ thông minh.**  
> Ứng dụng giúp bạn cải thiện thói quen đọc sách, quản lý thư viện đồ sộ, ghi chú khoa học và lưu trữ kiến thức dài hạn.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

---

## 🌟 Giới thiệu

**Trạm Đọc** là một dự án ứng dụng di động được xây dựng bằng **Flutter**, kết hợp backend từ **Firebase** và **Supabase**. Sứ mệnh của dự án là trở thành "Trợ lý đắc lực" cho những người đam mê đọc sách. Ứng dụng không chỉ hỗ trợ người dùng xây dựng nền tảng thói quen đọc mà còn cung cấp hệ thống học tập ngắt quãng (Spaced Repetition) độc đáo, giúp trích xuất và ghi nhớ kiến thức hiệu quả trong dài hạn.

---

## ✨ Tính năng nổi bật

📖 **Thư viện sách cá nhân**
- Quản lý kho sách theo cấp độ, tiến độ đọc và đánh giá bản thân.
- Tìm kiếm sách, phân loại tự động, lưu trữ thư viện mọi lúc, mọi nơi.
- Lưu lại những câu trích dẫn hay, bài học rút ra trong từng quyển.

✍️ **Trợ lý Ghi chú & OCR nhanh chóng**
- Tích hợp trình soạn thảo văn bản (Hỗ trợ định dạng đầy đủ: in đậm, in nghiêng, trích dẫn, tạo danh sách).
- Sử dụng **Camera** để quét, nhận diện và trích xuất văn bản sách giấy (Text Recognition OCR) thẳng vào ghi chú.

🧠 **Flashcard & Ôn tập ngắt quãng (Spaced Repetition)**
- Dễ dàng chuyển đổi những ghi chú quan trọng thành các bộ Flashcard.
- Thuật toán ôn tập thông minh, tự động điều chỉnh lịch ôn tập cá nhân.
- Theo dõi chuỗi ngay học (Streak), độ khó, tần suất ôn.
- Hệ thống nhắc nhở định kỳ thông qua thông báo đẩy hàng ngày.

🤝 **Kết nối & Cộng đồng**
- Tìm hiểu thư viện của bạn bè (Friend suggestions, Profile viewing).
- Nhắn tin trực tiếp với bạn bè hoặc Admin ứng dụng qua tính năng hỗ trợ trực tuyến.

---

## 🛠️ Công nghệ sử dụng (Tech Stack)

### **Frontend & State Management**
- **[Flutter](https://flutter.dev/) (Dart)** - Phiên bản SDK `^3.10.1` 
- **[Riverpod](https://riverpod.dev/)** - Quản lý trạng thái tin cậy, linh hoạt.
- **`flutter_staggered_grid_view`**, **`google_fonts`**, **`cupertino_icons`** - Thiết kế bộ khung UI mượt mà, ấn tượng.

### **Backend & Database**
- **[Firebase](https://firebase.google.com/)** (Auth, Cloud Firestore, Cloud Storage) - Quản lý đăng nhập, và dữ liệu linh hoạt.
- **[Supabase](https://supabase.com/)** (PostgreSQL) - Hỗ trợ lưu trữ thiết lập người dùng mạnh mẽ.

### **AI & Plugins Dịch vụ**
- **`google_mlkit_text_recognition`** - Google ML Kit tích hợp nhận diện chữ viết qua Camera máy.
- **`mobile_scanner` & `image_picker`** - Quét và xử lý hình thu nạp vào app nhanh chóng.
- **`flutter_local_notifications` & `timezone`** - Lập lịch nhắc nhở bộ nhớ cục bộ.

---

## 🚀 Hướng dẫn cài đặt (Getting Started)

### **1. Yêu cầu**
- Thiết bị đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.10.1`).
- IDE lập trình: **Android Studio**, **VS Code** hoặc **Xcode** (để chạy giả lập iOS).

### **2. Cài đặt chi tiết**

**Bước 1:** Clone repository
```bash
git clone https://github.com/hoangthi2509/App_Tro_Ly_Doc_Sach_Chu_Dong__Ghi_Nho.git
cd App_Tro_Ly_Doc_Sach_Chu_Dong__Ghi_Nho/reading_station_app
```

**Bước 2:** Cài đặt các Package phụ thuộc
```bash
flutter pub get
```

**Bước 3:** Cấu hình Backend (Dành cho Coder/Developer)
> ⚠️ **Lưu ý:** Bạn cần thiết lập bộ file cấu hình của Firebase/Supabase trong dự án để kết nối đến cơ sở dữ liệu.
- Định cấu hình và đưa các khóa dự án Supabase, Firebase tương ứng.

**Bước 4:** Chạy ứng dụng trên máy ảo hoặc thiết bị thực của bạn
```bash
flutter run
```

---

## 📂 Tổ chức dự án

Thư mục chính chứa mã nguồn chuyên sâu Flutter nằm trong thư mục `/reading_station_app/lib`:
- 📁 `views/`: Các màn hình, UI hiển thị toàn app.
- 📁 `controllers/` & `providers/`: State Management và xử lý logic chức năng nghiệp vụ.
- 📁 `models/`: Định nghĩa các bộ Object truyền dẫn cơ bản (`Book`, `Note`, `User`, ...).
- 📁 `repositories/`: Tầng kết nối Database (giao tiếp cùng API, Supabase, Firebase).

*👉 Tham khảo chi tiết tại [PROJECT_MAP.md](reading_station_app/PROJECT_MAP.md) bên trong gốc source code!*

---

## 🤝 Đóng góp (Contributing)
Mọi ý kiến đóng góp, báo cáo lỗi hay gợi ý tính năng đều là phần quan trọng để hoàn thiện dự án!

1. Fork repo này lại.
2. Tạo cho mình nhánh mới (`git checkout -b feature/TínhNăngHay`).
3. Commit cập nhật (`git commit -m 'Thêm một vài Tính Năng Hay'`).
4. Push mã nguồn vào nhánh (`git push origin feature/TínhNăngHay`).
5. Mở một **Pull Request** cho chúng tôi xem xét.

---

<p align="center">
  Cám ơn bạn vì đã ghé qua và quan tâm dự án <strong>Trạm Đọc</strong>! Chúc bạn có trải nghiệm và hành trình đọc sách thật giá trị! ❤️
</p>
