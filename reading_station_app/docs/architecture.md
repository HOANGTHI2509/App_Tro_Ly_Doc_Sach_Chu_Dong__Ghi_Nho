# 🏗️ Tổng Quan Kiến Trúc (Reading Station)

## Stack Công Nghệ

```mermaid
graph TB
    subgraph "Frontend - Flutter"
        A[Mobile App iOS/Android]
        B[State Management - Provider/Riverpod]
        C[Local Storage - Hive/SQLite]
    end
    
    subgraph "Backend - Firebase"
        D[Firebase Auth]
        E[Cloud Firestore]
        F[Cloud Storage]
        G[Cloud Functions]
        H[Cloud Messaging FCM]
    end
    
    subgraph "External Services"
        I[Google Books API]
        J[Google ML Kit OCR]
        K[Barcode Scanner]
    end
    
    A --> B
    B --> C
    A --> D
    A --> E
    A --> F
    B --> G
    G --> I
    A --> J
    A --> K
    G --> H
```

## Nguyên Tắc Thiết Kế
- **Offline-First**: App hoạt động mượt mà khi không có mạng
- **Clean Architecture**: Tách biệt UI, Business Logic, Data Layer
- **Responsive Design**: Tối ưu cho nhiều kích thước màn hình
- **Security-First**: Mọi dữ liệu đều được bảo vệ bởi Firebase Rules
