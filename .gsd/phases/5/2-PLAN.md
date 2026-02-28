---
phase: 5
plan: 2
wave: 2
---

# Plan 5.2: UI Polish & Final Adjustments

## Objective
Finalize the MVP with UI polish, error handling, and making sure the entire flow feels premium and complete.

## Context
- .gsd/SPEC.md
- lib/features/bookings/presentation/booking_list_screen.dart
- lib/features/calendar/presentation/calendar_screen.dart
- lib/core/theme/app_theme.dart

## Tasks

<task type="auto">
  <name>Empty states and error boundaries</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/bookings/presentation/booking_list_screen.dart
    /home/ashish/MyProjects/Homestay/lib/features/calendar/presentation/calendar_screen.dart
  </files>
  <action>
    1. Review list screens (bookings, calendar) to ensure visually pleasing empty states when there is no data.
    2. Add fallback or retry mechanisms where appropriate (e.g., if Firestore connection is flaky, though Riverpod streams handle reconnects, ensure the UI reflects loading/error gracefully).
    3. Ensure the active status filters on booking list perfectly handle empty filtered lists with distinct messaging (e.g., "No cancelled bookings").
  </action>
  <verify>flutter analyze lib/</verify>
  <done>Empty states are polished and descriptive across all lists</done>
</task>

<task type="auto">
  <name>Theme and typography polish</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/core/theme/app_theme.dart
    /home/ashish/MyProjects/Homestay/lib/features/dashboard/presentation/dashboard_screen.dart
  </files>
  <action>
    1. Audit Material 3 typography (Outfit font) to ensure correct font weights are used for headers vs body text.
    2. Ensure the Dashboard gradient header looks crisp.
    3. Check that Room cards have appropriate elevation and ripple effects (`InkWell`) where interactive.
  </action>
  <verify>flutter analyze lib/core/theme/</verify>
  <done>Theme uses consistent typography and colors, UI components have expected interactive feedback</done>
</task>

## Success Criteria
- [ ] Booking list empty states are descriptive
- [ ] App theme typography is consistently applied
- [ ] All interactive elements provide touch feedback (ripples/colors)
- [ ] `flutter analyze` passes with 0 issues
