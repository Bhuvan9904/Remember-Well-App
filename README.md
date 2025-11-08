# Remember Well

Remember Well is a Flutter application that helps users capture memories,
organize them with rich metadata, and build a personalized recall plan that
strengthens long-term retention. The project targets mobile and desktop
platforms using a single codebase.

## Features

- **Guided onboarding** that collects preferences to personalize the recall
  cadence.
- **Memory vault** with tagging, mood tracking, and file attachments to keep
  memories vivid.
- **Adaptive recall modes** (battle, guided paths, quizzes, random replay) that
  adjust difficulty based on previous performance.
- **Progress dashboard** to review streaks, recall quality, and upcoming memory
  sessions.
- **Cross-platform support** for Android, iOS, web, Windows, macOS, and Linux.

## Tech Stack

- Flutter 3.x with Material 3 theming
- Hive for local persistence
- Riverpod (or Provider) for state management
- Dart build_runner for model serialization

## Getting Started

### Prerequisites

- Flutter SDK 3.22 or newer
- Dart SDK (bundled with Flutter)
- Xcode (for iOS/macOS builds)
- Android Studio or command-line Android build tools

### Setup

```bash
# clone the repository
git clone https://github.com/Bhuvan9904/Remember-Well-App.git
cd Remember-Well-App

# fetch dependencies
flutter pub get
```

### Generate Hive adapters (when models change)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run the app

```bash
flutter run
```

By default, Flutter detects connected devices or emulators. Use
`flutter devices` to list available targets and
`flutter run -d <device_id>` to run on a specific device.

## Project Structure

- `lib/core`: Shared constants, theming, routes, and utilities.
- `lib/data`: Hive models, repositories, and persistence services.
- `lib/features`: Feature-first UI organization (home, memory, recall, progress,
  onboarding, settings, vault).
- `test`: Widget and unit tests.

## Contributing

Issues and pull requests are welcome. To propose a change:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Commit your changes and push the branch.
4. Open a pull request describing your update and test coverage.

## License

This project is currently unlicensed. Please contact the repository owner before
reusing the code in another project.
