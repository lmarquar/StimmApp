# Project Development Guidelines

This document provides essential information for developing, building, and testing the Stimmapp project.

---

### 🛠 Build & Configuration

- **Environment**: x64 based
- **Flutter SDK**: `3.38.3`
- **Dart SDK**: `3.10.1`
- **Ausweis APP**: `2.4.0`

#### Initialization
To initialize dependencies and generate files (e.g., localizations), run:
```bash
flutter pub get
```

---

### 🧪 Testing

Core functionality is validated using standard Flutter tests. Ensure all tests pass before submitting changes.

- **Run all tests**: `flutter test`
- **Key Test Areas**:
  - **Models**: `test/core/data/models/`
  - **Repositories**: `test/core/data/repositories/`

---

### 💡 Development Information

#### Navigation & UI Feedback
- **Navigator Key**: A global `navigatorKey` is defined in `lib/main.dart`.
  - **Usage**: Primarily reserved for **Firebase** operations, deep linking, or when `BuildContext` is unavailable.
  - **Constraint**: Avoid using it for general navigation if a local `BuildContext` is accessible.
- **Messenger Service**: Located at `lib/core/functions/messenger_service.dart`.
  - **Purpose**: Recommended for handling **popup windows** and snackbars.
  - **Benefit**: Decouples UI feedback from specific `BuildContext` requirements.
- **Feedback Utilities**: Prefer using `MessengerService` or `snackbar_utils.dart` for showing snackbars, errors, or success messages.

#### Identity Check (AusweisApp)
For Identity-check implementation, the **AusweisApp API Wrapper** is used.
- **Location**: `external/AusweisApp-SDK-Wrapper/`
- **Documentation**: [AusweisApp SDK Wrapper Docs](https://www.ausweisapp.bund.de/sdkwrapper/index.html)

---

> [!TIP]
> Make adjustments to this file if it helps improve development efficiency.