---
phase: 1
plan: 2
wave: 1
---

# Plan 1.2: Firebase Configuration & Auth Setup

## Objective
Configure Firebase for the Flutter project (Android + iOS), set up Firebase Auth with email/password, and create the login screen.

## Context
- .gsd/SPEC.md
- .gsd/DECISIONS.md (ADR-002, ADR-005, ADR-009)
- lib/main.dart
- pubspec.yaml

## Tasks

<task type="checkpoint:human-verify">
  <name>Firebase configuration files</name>
  <files>
    /home/ashish/MyProjects/Homestay/android/app/google-services.json
    /home/ashish/MyProjects/Homestay/ios/Runner/GoogleService-Info.plist
  </files>
  <action>
    1. Check if user has created Firebase project and downloaded config files
    2. If flutterfire_cli is available, run `flutterfire configure` to auto-configure
    3. Otherwise, guide user to place:
       - `google-services.json` in `android/app/`
       - `GoogleService-Info.plist` in `ios/Runner/`
    4. Update `android/build.gradle` and `android/app/build.gradle` with Firebase plugins
    5. Initialize Firebase in `main.dart`:
       ```dart
       await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );
       ```
    - Do NOT hardcode API keys in source code
    - Ensure .gitignore excludes sensitive Firebase files if needed
  </action>
  <verify>flutter build apk --debug 2>&1 | head -20 (should not show Firebase config errors)</verify>
  <done>Firebase initializes without errors on app launch</done>
</task>

<task type="auto">
  <name>Auth service and login screen</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/auth/data/auth_repository.dart
    /home/ashish/MyProjects/Homestay/lib/features/auth/domain/auth_state.dart
    /home/ashish/MyProjects/Homestay/lib/features/auth/presentation/login_screen.dart
    /home/ashish/MyProjects/Homestay/lib/shared/providers/auth_provider.dart
  </files>
  <action>
    1. Create AuthRepository class:
       - signInWithEmailAndPassword(email, password)
       - signOut()
       - authStateChanges stream
       - currentUser getter
    2. Create Riverpod providers:
       - authRepositoryProvider
       - authStateProvider (StreamProvider from authStateChanges)
    3. Create LoginScreen:
       - Email field with validation
       - Password field with visibility toggle
       - Sign in button with loading state
       - Error display (wrong credentials, etc.)
       - Modern Material 3 design with homestay branding
       - No "Sign up" or "Forgot password" links (owners pre-created in Firebase)
    4. Set up GoRouter with auth redirect:
       - If not authenticated → LoginScreen
       - If authenticated → DashboardScreen (placeholder for now)
    - Do NOT add registration flow
    - Do NOT add social login
  </action>
  <verify>flutter analyze lib/features/auth/</verify>
  <done>Login screen renders, accepts email/password, and auth state is tracked via Riverpod</done>
</task>

## Success Criteria
- [ ] Firebase initializes without errors
- [ ] Login screen shows email/password fields
- [ ] Auth state changes are tracked via Riverpod StreamProvider
- [ ] GoRouter redirects unauthenticated users to login
