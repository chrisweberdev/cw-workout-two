# CW Hybrid Training

A Flutter-based hybrid training tracker with GPT coaching support. Track strength workouts, running sessions, and HIIT training all in one app. Available as a Progressive Web App (PWA).

## Live App

**[https://chrisweberdev.github.io/cw-workout-two/](https://chrisweberdev.github.io/cw-workout-two/)**

## Features

### Training Modes
- **Strength Training** - Track sets, reps, and weights with exercise library
- **Running** - Log runs with distance, time, and run type
- **HIIT** - Track high-intensity interval training sessions

### Core Features
- **Workout Plans** - Create custom plans organized by muscle groups
- **Exercise Library** - Comprehensive database by category
- **GPT Coaching** - AI-powered feedback and recommendations (supports custom GPT URL)
- **Weekly Schedule** - Plan workouts by day of the week
- **Body Scan Tracking** - Monitor body measurements and composition
- **Analytics Dashboard** - View statistics, trends, and progress
- **Personal Records** - Track PRs across all training types
- **Dark Theme** - Modern UI optimized for gym use
- **Offline Support** - Full PWA offline capability

### Data Management
- **Manual Backup** - Export/import data as JSON
- **GitHub Backup** - Cloud sync via GitHub integration

---

## Installing the PWA

### iOS (iPhone/iPad)

1. Open **Safari** and navigate to the app URL
2. Tap the **Share** button (square with arrow pointing up)
3. Scroll down and tap **"Add to Home Screen"**
4. Name the app and tap **"Add"**

### Android

1. Open **Chrome** and navigate to the app URL
2. Tap the **three-dot menu** in the top right
3. Tap **"Add to Home Screen"** or **"Install App"**
4. Confirm by tapping **"Add"**

### Desktop (Chrome/Edge)

1. Navigate to the app URL
2. Click the **install icon** in the address bar
3. Click **"Install"** in the prompt

### Desktop (Safari on Mac)

1. Navigate to the app URL
2. Click **File** > **Add to Dock**

---

## Updating the App (Without Data Loss)

PWA updates are automatic and preserve your data:

1. Close the app completely
2. Reopen from your home screen
3. The app loads the latest version with all data intact

**NEVER delete and re-add the PWA** - this causes complete data loss.

---

## iOS Data Considerations

| Condition | Risk |
|-----------|------|
| App not opened for 7+ days | Safari may evict data |
| Device low on storage | Data may be cleared |
| Deleting PWA from home screen | **Permanent data loss** |

**Best practices:** Open the app regularly and create backups via Settings.

---

## Development

### Prerequisites
- Flutter SDK 3.10.1 or higher
- Dart SDK

### Running Locally

```bash
# Get dependencies
flutter pub get

# Generate Hive adapters (if needed)
flutter packages pub run build_runner build

# Run on Chrome
flutter run -d chrome

# Run on iOS Simulator
flutter run -d ios

# Run on macOS
flutter run -d macos
```

### Building for Deployment

```bash
flutter build web --release --base-href "/cw-workout-two/"
```

See [CLAUDE.md](CLAUDE.md) for full deployment instructions.

---

## Project Structure

```
lib/
├── main.dart           # App entry point
├── data/
│   ├── repository.dart # Data access layer
│   └── fixture_data.dart
├── models/             # Data models with Hive adapters
├── services/
│   └── github_service.dart
├── theme/
│   └── theme_manager.dart
├── ui/                 # Screen widgets
│   ├── shell.dart
│   ├── dashboard_screen.dart
│   ├── strength_workout_screen.dart
│   ├── running_log_screen.dart
│   ├── hiit_log_screen.dart
│   ├── body_scan_screen.dart
│   └── ...
└── widgets/            # Reusable components
```

---

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Hive** - Local NoSQL database (IndexedDB on web)
- **Provider** - State management
- **FL Chart** - Analytics visualization
- **HTTP** - GPT API integration

---

## License

Private project - All rights reserved
