---
phase: 3
plan: 2
wave: 2
---

# Plan 3.2: Routing & Navigation Integration

## Objective
Add the calendar screen to the app navigation and update GoRouter routes. Add calendar tab to bottom navigation.

## Context
- lib/app.dart (router and routes)
- lib/shared/widgets/app_scaffold.dart (bottom nav)
- lib/features/calendar/presentation/calendar_screen.dart

## Tasks

<task type="auto">
  <name>Add calendar to navigation</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/app.dart
    /home/ashish/MyProjects/Homestay/lib/shared/widgets/app_scaffold.dart
  </files>
  <action>
    1. Add /calendar route to GoRouter ShellRoute:
       - path: /calendar → CalendarScreen (with bottom nav)
    2. Update AppScaffold bottom NavigationBar:
       - Change tabs to: Dashboard | Calendar | Bookings | Rooms (4 tabs)
       - Calendar gets calendar_month icon
       - Update _calculateSelectedIndex and _onItemTapped for 4 tabs
    3. Update dashboard "upcoming bookings" section with "View Calendar" link

    - MUST preserve existing auth redirect logic
    - MUST use NoTransitionPage for calendar route
    - Bottom nav should highlight correctly for all 4 tabs
  </action>
  <verify>flutter analyze lib/</verify>
  <done>Calendar tab visible in bottom nav, route works, all 4 tabs navigate correctly</done>
</task>

## Success Criteria
- [ ] Calendar accessible from bottom navigation
- [ ] All 4 tabs (Dashboard, Calendar, Bookings, Rooms) work correctly
- [ ] Auth redirect still protects calendar route
- [ ] `flutter analyze` passes for entire lib/
