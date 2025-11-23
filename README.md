# AeroFocus

AeroFocus is a lightweight Flutter focus timer inspired by flight. It features a curved progress path with a paper-plane marker, Pomodoro-style auto break handling, streak tracking, and local-only storage.

## Run the app
1. Install Flutter (3.19+ recommended) and run `flutter pub get` in this folder.
2. Connect an Android device or start an emulator.
3. Run `flutter run` to launch AeroFocus.

## Build the APK
```
flutter build apk --release
```
The output will be in `build/app/outputs/flutter-apk/app-release.apk`.

## Replace assets
- Base64 placeholders live in `assets/plane_base64.txt` and `assets/cloud_base64.txt`. Each file contains a data URI for a simple SVG.
- To use your own images, add them under `assets/` (for example `assets/plane.png` and `assets/cloud.png`), list them in `pubspec.yaml` under `flutter/assets`, then run `flutter pub get`.

## Folder structure
- `lib/` — app code organized into screens, components, services, models, and utilities.
- `assets/` — base64 text placeholders for the plane and cloud accents.
- `pubspec.yaml` — dependencies and asset declarations.

## Notes
- All data is stored locally via `SharedPreferences`. Export/backup creates a JSON file in the app documents directory.
- Notifications use `flutter_local_notifications` with a simple high-priority channel.
