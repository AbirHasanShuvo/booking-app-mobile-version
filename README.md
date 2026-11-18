# Service Booking App (Flutter)

A cross-platform mobile app where customers explore services, book appointments, manage their bookings, and get help from an AI assistant.



## Screenshots

| Login | Home | Service details |
|---|---|---|
| ![Login](screenshots/login.png) | ![Home](screenshots/home.png) | ![Details](screenshots/details.png) |

| Booking | My bookings | Assistant |
|---|---|---|
| ![Booking](screenshots/booking.png) | ![Bookings](screenshots/bookings.png) | ![Assistant](screenshots/assistant.png) |

---

## Features

- **Authentication:** register, login, logout, form validation, error messages, and a session that persists after the app is closed (JWT stored in secure storage)
- **Home:** service list with image, name, description and price; search with debounce; category filter; "Popular services" section
- **Service details:** full information, price, estimated duration, Book now
- **Booking:** 14-day date picker, time slots from the server (booked and past slots are disabled), optional notes, confirmation screen
- **My bookings:** upcoming and past tabs, booking details, cancel pending bookings with a confirm dialog, status chips (Pending, Confirmed, Cancelled, Completed)
- **Profile:** view and edit name, email and phone; change password; logout with confirmation
- **AI assistant:** chat about services and get recommendations (the AI key stays on the backend)
- **UX:** loading, empty, success and error states on every screen, pull to refresh, retry buttons, reusable widgets

---

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter and Dart |
| State management | Riverpod (`Notifier`, `FutureProvider`) |
| Networking | Dio with an auth interceptor |
| Navigation | go_router (auth redirects, bottom navigation shell) |
| Secure storage | flutter_secure_storage |
| Images | cached_network_image |
| Formatting | intl |

---

## Architecture

Feature-first structure with a simple layering inside each feature:

```
lib/
  core/
    config/       app_config.dart          (API base URL)
    network/      dio_client.dart, api_exception.dart
    storage/      token_storage.dart
    theme/        app_theme.dart
    utils/        formatters.dart
    widgets/      app_button, app_text_field, state_views, status_chip
  features/
    auth/         data/ (model, repository)  presentation/ (controller, screens)
    services/     data/  presentation/ (providers, home, details, widgets)
    booking/      booking screen, confirmation screen
    bookings/     data/  presentation/ (my bookings, details, providers)
    profile/      profile, edit profile, change password
    ai_chat/      data/  presentation/ (controller, chat screen)
    shell/        main_shell.dart          (bottom navigation)
  app_router.dart
  main.dart
```

Data flow: **Screen → Riverpod notifier/provider → Repository → Dio → REST API.**

- Screens contain UI only.
- Repositories are the only place that talks to the API and convert Dio errors into a single `ApiException`.
- Models parse JSON (for example Laravel returns decimals as strings, and the models handle that).

### Notable decisions

- **Session restore:** on app start, the auth controller reads the token from secure storage and calls `/me`. If it succeeds, the user goes straight to Home.
- **Expired token handling:** the Dio interceptor clears the token and returns the user to Login on any 401 from a protected request.
- **Slot conflicts:** the app only shows what the server says is available. If another user takes a slot first, the API returns 409, and the app refreshes the slots and asks the user to choose again.
- **Per-user state:** bookings and chat providers watch the logged-in user's id, so one user never sees another's cached data after switching accounts.
- **Secrets:** the app contains no AI key. All AI calls go through the backend.

---

## Setup

### Requirements

- Flutter SDK (stable) with Dart 3+
- Android Studio or VS Code with an emulator, or a real Android device
- The backend running locally or deployed (see the backend repo)

### Run

```bash
git clone https://github.com/YOUR_USERNAME/service_booking_app.git
cd service_booking_app
flutter pub get
```

The API base URL is set at build time with `--dart-define`. The default is `http://10.0.2.2:8000/api`, which is how the Android emulator reaches `localhost` on your computer.

```bash
# Android emulator + local backend (default URL)
flutter run

# Deployed backend
flutter run --dart-define=API_BASE_URL=https://YOUR_DEPLOYED_URL/api

# Real phone + local backend on the same Wi-Fi
flutter run --dart-define=API_BASE_URL=http://192.168.X.X:8000/api
```

For the last option, start Laravel with `php artisan serve --host=0.0.0.0`.

### Build the APK

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR_DEPLOYED_URL/api
```

The APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

### Android configuration

- `android/app/src/main/AndroidManifest.xml` declares the `INTERNET` permission (required for release builds).
- `android:usesCleartextTraffic="true"` is enabled only so local `http://` development works. It can be removed when the app only talks to an HTTPS backend.
- `minSdk` is set to 23 (required by `flutter_secure_storage`).

---

## Demo account

Register a new account in the app, or use: `YOUR_DEMO_EMAIL` / `YOUR_DEMO_PASSWORD`

---

## Backend API

The app uses these endpoints (full docs in the backend repo's `docs/api.md`):

`/auth/register`, `/auth/login`, `/auth/logout`, `/me`, `/me/password`, `/categories`, `/services`, `/services/{id}`, `/services/{id}/availability`, `/appointments`, `/appointments/{id}`, `/appointments/{id}/cancel`, `/ai/chat`
