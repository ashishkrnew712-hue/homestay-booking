---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Flutter Project Scaffolding

## Objective
Install Flutter SDK (if missing), create the Flutter project, and set up the folder structure with core dependencies (Riverpod, Firebase packages, go_router).

## Context
- .gsd/SPEC.md
- .gsd/DECISIONS.md (ADR-001, ADR-002, ADR-008)

## Tasks

<task type="auto">
  <name>Install Flutter SDK</name>
  <files>~/.local/share/flutter (or system Flutter path)</files>
  <action>
    Check if Flutter is installed. If not:
    1. Download Flutter SDK via `git clone https://github.com/flutter/flutter.git` or snap
    2. Add to PATH
    3. Run `flutter doctor` to verify
    - Ensure stable channel is used
    - Do NOT install Android Studio (use command line tools only if needed)
  </action>
  <verify>flutter --version</verify>
  <done>Flutter SDK is installed and `flutter doctor` runs without blocking errors</done>
</task>

<task type="auto">
  <name>Create Flutter project with dependencies</name>
  <files>
    /home/ashish/MyProjects/Homestay/pubspec.yaml
    /home/ashish/MyProjects/Homestay/lib/main.dart
  </files>
  <action>
    1. Run `flutter create --org com.homestay --project-name homestay_booking .` in the project root
    2. Add dependencies to pubspec.yaml:
       - firebase_core
       - firebase_auth
       - cloud_firestore
       - firebase_messaging
       - flutter_riverpod
       - riverpod_annotation
       - go_router
       - intl
       - google_fonts
    3. Add dev dependencies:
       - riverpod_generator
       - build_runner
       - riverpod_lint
    4. Run `flutter pub get`
    - Do NOT delete .gsd/ or .agent/ or .gemini/ directories
    - Do NOT overwrite existing project files (scripts/, docs/, adapters/, etc.)
  </action>
  <verify>flutter pub get && echo "Dependencies resolved"</verify>
  <done>Flutter project created, all dependencies resolve without errors</done>
</task>

<task type="auto">
  <name>Set up project folder structure</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/
  </files>
  <action>
    Create the following directory structure under lib/:
    ```
    lib/
    ├── main.dart
    ├── app.dart                    # MaterialApp with GoRouter
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart  # App-wide constants
    │   ├── theme/
    │   │   └── app_theme.dart      # Material 3 theme
    │   └── utils/
    │       └── date_utils.dart     # Date helper functions
    ├── features/
    │   ├── auth/
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/
    │   ├── bookings/
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/
    │   ├── rooms/
    │   │   ├── data/
    │   │   ├── domain/
    │   │   └── presentation/
    │   └── dashboard/
    │       └── presentation/
    └── shared/
        ├── models/
        ├── providers/
        └── widgets/
    ```
    - Use feature-first architecture (scalable for future)
    - Create placeholder files with TODO comments in each directory
  </action>
  <verify>find lib/ -type d | sort</verify>
  <done>All directories created under lib/ matching the structure above</done>
</task>

## Success Criteria
- [ ] `flutter --version` returns a valid Flutter version
- [ ] `flutter pub get` succeeds with all dependencies
- [ ] lib/ directory structure matches the plan
