# AeroFocus

A Jetpack Compose Android MVP that turns focus sessions into flights. Pick a route and duration, watch your plane glide along a map with a subtle cloud overlay, and keep your timer running in a foreground service so focus survives backgrounding and lock screen.

## Features
- Kotlin + Jetpack Compose + Material 3 UI
- Navigation between Booking, In-Flight, Summary, and History screens
- Foreground service-powered timer with persistent notification and pause/resume
- Google Maps Compose for displaying routes, markers, and plane progress
- Lottie overlay for animated clouds (replaceable JSON asset)
- Room database for completed sessions and basic streak/total stats
- Predefined list of 20 cities for quick route selection
- GitHub Actions workflow that builds and uploads a debug APK plus unit test reports

## Project Structure
- `app/src/main/java/com/aerofocus` — Application, UI screens, navigation, and services
- `data/` — Room entities, DAO, and repository implementation
- `domain/` — Models and repository contract
- `ui/screens` — Booking, In-Flight, Summary, and History composables with ViewModels
- `service/SessionService` — Foreground service owning the timer and notification
- `util/` — City list, route math, and time formatting helpers

## Building locally
1. Ensure you have JDK 17 installed.
2. Install Gradle 8.10.2 (the wrapper is not included to keep the repo binary-free). You can download it from https://gradle.org/releases/ and add `gradle-8.10.2/bin` to your `PATH`.
3. Add your Google Maps API key (see below).
4. From the repo root, run:
   ```bash
   gradle assembleDebug
   gradle test
   ```
5. The debug APK will be at `app/build/outputs/apk/debug/app-debug.apk`.

## Google Maps API Key
1. Create an API key in the Google Cloud console with Maps SDK for Android enabled.
2. Open `app/src/main/res/values/strings.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY` for the `google_maps_key` string.
3. No other changes are required—the Maps Compose component reads this value automatically.

## Replacing the cloud Lottie animation
- Swap `app/src/main/assets/clouds.json` with your desired cloud animation file (same name/path).
- The In-Flight screen will automatically render it with a subtle opacity overlay.

## GitHub Actions CI
The workflow at `.github/workflows/android.yml` runs on every push/PR:
- Builds the debug APK with `./gradlew assembleDebug`
- Runs unit tests with `./gradlew test`
- Uploads the APK and unit test reports as build artifacts

## Notes
- Minimum SDK: 24, Target SDK: 34
- Foreground service keeps the timer alive and shows a persistent “In Flight” notification while running.
- Sessions save locally (start/end, duration, route, completion flag) for the History view and streak/total stats.
