# 🗺️ Project Map - Trạm Đọc (Reading Station)

This document provides a quick overview of the project structure for AI agents and developers.

## 📂 Core Directory Structure (`lib/`)

- **`config/`**: App-wide configuration, constants, and themes.
- **`controllers/`**: Logic for managing app state and user interactions.
- **`features/`**: Modular feature implementations.
- **`models/`**: Data classes (e.g., `Book`, `Note`, `User`).
- **`providers/`**: State management providers (e.g., Riverpod/Provider).
- **`repositories/`**: Abstraction layer for data sources (Supabase, Firebase).
- **`services/`**: Low-level service implementations (API clients, local storage).
- **`views/`**: UI screens and reusable widgets, organized by feature.

## 📖 Documentation (`docs/`)
- **`architecture.md`**: Tech stack and design principles.
- **`database_schema.md`**: Firestore collections and indexes.
- **`phase1_foundation.md`** to **`phase4_polish.md`**: Modular roadmap by phase.
- **`security_rules.md`**: Firebase security logic.
- **`devops_deployment.md`**: CI/CD and monitoring.

## 📁 Other Key Directories

- **`assets/`**: Images, fonts, and static data.
- **`test/`**: Unit and widget tests.
- **`logs/`**: Diagnostic output and build logs (Ignored by AI).

## 💡 Efficiency Tips for AI
- Use `lib/views/` for UI changes.
- Use `lib/models/` and `lib/repositories/` for data logic.
- Avoid scanning `android/`, `ios/`, or `build/` unless debugging platform-specific issues.
