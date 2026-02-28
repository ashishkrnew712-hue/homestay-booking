---
phase: 4
plan: 2
wave: 2
---

# Plan 4.2: Routing & Integration

## Objective
Wire up the room settings screen into GoRouter and add edit button to the room list screen.

## Context
- lib/app.dart
- lib/features/rooms/presentation/room_list_screen.dart
- lib/features/rooms/presentation/room_settings_screen.dart

## Tasks

<task type="auto">
  <name>Add room settings route and edit action</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/app.dart
    /home/ashish/MyProjects/Homestay/lib/features/rooms/presentation/room_list_screen.dart
  </files>
  <action>
    1. Add route to GoRouter:
       - /rooms/:id/edit → RoomSettingsScreen (full-screen, parentNavigatorKey: _rootNavigatorKey)
    2. Update RoomListScreen:
       - Add edit icon button on each room card
       - Tap edit navigates to /rooms/{roomId}/edit
    3. Import RoomSettingsScreen in app.dart

    - Auth redirect must protect the new route
    - Room ID passed as path parameter
  </action>
  <verify>flutter analyze lib/</verify>
  <done>Room edit route works, edit button on room cards navigates to settings screen</done>
</task>

## Success Criteria
- [ ] Room settings accessible from room list
- [ ] Route passes room ID correctly
- [ ] `flutter analyze` passes for entire lib/
