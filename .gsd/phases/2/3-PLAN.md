---
phase: 2
plan: 3
wave: 2
---

# Plan 2.3: Navigation & Routing Integration

## Objective
Wire all screens together with GoRouter navigation, add bottom navigation bar, and ensure the complete booking CRUD flow works end-to-end.

## Context
- lib/app.dart (current router)
- lib/features/dashboard/presentation/dashboard_screen.dart
- lib/features/bookings/presentation/*.dart
- lib/features/rooms/domain/room_model.dart

## Tasks

<task type="auto">
  <name>Complete routing and navigation</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/app.dart
    /home/ashish/MyProjects/Homestay/lib/shared/widgets/app_scaffold.dart
  </files>
  <action>
    1. Update GoRouter in app.dart with all routes:
       - / → DashboardScreen (with bottom nav)
       - /bookings → BookingListScreen (with bottom nav)
       - /bookings/create → CreateBookingScreen
       - /bookings/:id → BookingDetailScreen
       - /bookings/:id/edit → EditBookingScreen
       - /login → LoginScreen

    2. Create AppScaffold widget with bottom navigation:
       - Dashboard tab (house icon)
       - Bookings tab (calendar icon)
       - Use GoRouter's ShellRoute for persistent bottom nav

    3. Add room list screen (simple):
       - List all 5 rooms from Firestore
       - Show room name, capacity, pricing
       - Tap to see room bookings

    - MUST use GoRouter's ShellRoute pattern for bottom navigation
    - MUST pass booking ID as path parameter for detail/edit routes
    - Auth redirect must still work correctly
  </action>
  <verify>flutter analyze lib/</verify>
  <done>All routes connected, bottom nav works, booking CRUD flow is navigable end-to-end</done>
</task>

<task type="auto">
  <name>Room list screen</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/rooms/presentation/room_list_screen.dart
  </files>
  <action>
    1. Create RoomListScreen:
       - Real-time list from roomsStreamProvider
       - Each room card shows:
         - Room name
         - Capacity (2 guests)
         - Pricing (single / double per night)
         - Current status (available / occupied)
         - Amenities as chips
       - Tap room to show its bookings (filtered booking list)
    2. Modern card-based design consistent with dashboard

    - Do NOT add room editing (future phase)
    - Use consistent Material 3 styling
  </action>
  <verify>flutter analyze lib/features/rooms/presentation/</verify>
  <done>Room list screen shows all rooms with status, pricing, and amenities</done>
</task>

## Success Criteria
- [ ] All screens reachable via GoRouter
- [ ] Bottom nav persists across Dashboard and Bookings tabs
- [ ] Create → List → Detail → Edit → Cancel flow works
- [ ] Room list shows live data
- [ ] Auth redirect still protects all routes
- [ ] `flutter analyze` passes for entire lib/
