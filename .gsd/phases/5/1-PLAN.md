---
phase: 5
plan: 1
wave: 1
---

# Plan 5.1: Push Notifications

## Objective
Implement Firebase Cloud Messaging (FCM) so owners get instantly notified when bookings are created, updated, or cancelled. Since both owners need to know about all changes, they will simply subscribe to a common topic, and a Firebase Cloud Function will broadcast changes to that topic.

## Context
- .gsd/SPEC.md (Notifications section)
- lib/main.dart (For FCM initialization)
- lib/features/dashboard/presentation/dashboard_screen.dart (For requesting permissions)

## Tasks

<task type="auto">
  <name>FCM package setup and initialization</name>
  <files>
    /home/ashish/MyProjects/Homestay/pubspec.yaml
    /home/ashish/MyProjects/Homestay/lib/main.dart
    /home/ashish/MyProjects/Homestay/lib/core/services/notification_service.dart
  </files>
  <action>
    1. Add `firebase_messaging` and `flutter_local_notifications` to pubspec.yaml.
    2. Create `NotificationService` class:
       - Handle permission requests (requestPermission)
       - Initialize flutter_local_notifications for foreground display
       - Subscribe device to FCM topic: `booking_updates`
       - Handle foreground messages (FirebaseMessaging.onMessage) by showing a local notification
    3. Update `main.dart`:
       - Define `@pragma('vm:entry-point')` background message handler for FCM
       - Initialize `NotificationService`
  </action>
  <verify>flutter analyze lib/core/services/ && flutter pub get</verify>
  <done>Flutter app is configured for FCM, requests permissions, and subscribes to `booking_updates` topic</done>
</task>

<task type="auto">
  <name>Firebase Cloud Function for booking events</name>
  <files>
    /home/ashish/MyProjects/Homestay/functions/package.json
    /home/ashish/MyProjects/Homestay/functions/index.js
  </files>
  <action>
    Create a Firebase Cloud Function to watch Firestore and trigger FCM via topic.
    1. Initialize a basic Node.js functions environment (no need for `firebase init` wizard if we just create the files manually).
    2. Write `index.js` using `firebase-functions/v2/firestore` (or v1) and `firebase-admin`:
       - Trigger on `onDocumentWritten('bookings/{bookingId}')`
       - Compare before/after state to determine if it was created, updated, or deleted
       - Construct notification payload (title: "New Booking", "Booking Updated", etc., body: "Room X for John Doe")
       - Send to topic `booking_updates` via `admin.messaging().send(message)`
    3. Note: Deployment of this function will be left to the user (requires Firebase Blaze plan), but the code MUST be ready.
  </action>
  <verify>test -f functions/index.js && test -f functions/package.json</verify>
  <done>Cloud function source code exists and is configured to send FCM messages on booking changes</done>
</task>

<task type="auto">
  <name>Request permissions on dashboard</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/dashboard/presentation/dashboard_screen.dart
  </files>
  <action>
    Update the Dashboard screen to initialize the NotificationService and request permissions when an owner logs in.
    - Call `NotificationService().initialize()` in initState or a useEffect hook.
    - This ensures that as soon as an owner logs in, they are subscribed to booking updates.
  </action>
  <verify>flutter analyze lib/features/dashboard/</verify>
  <done>Dashboard triggers notification permission request</done>
</task>

## Success Criteria
- [ ] FCM and local notifications packages added
- [ ] App subscribes to `booking_updates` topic
- [ ] Foreground messages show local notifications
- [ ] Cloud Function script watches `bookings` collection and sends to FCM
- [ ] `flutter analyze` passes
