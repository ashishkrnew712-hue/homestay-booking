---
phase: 2
plan: 2
wave: 1
---

# Plan 2.2: Edit Booking & Dashboard

## Objective
Build the booking edit flow and replace the placeholder dashboard with a real owner dashboard showing today's activity and room status at a glance.

## Context
- lib/features/bookings/presentation/create_booking_screen.dart (pattern to follow/extend)
- lib/features/bookings/data/booking_repository.dart
- lib/features/rooms/domain/room_model.dart
- lib/features/dashboard/presentation/dashboard_screen.dart (replace placeholder)
- lib/shared/providers/firestore_providers.dart

## Tasks

<task type="auto">
  <name>Edit booking screen</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/bookings/presentation/edit_booking_screen.dart
  </files>
  <action>
    1. Create EditBookingScreen that reuses the booking form pattern:
       - Pre-populate all fields from existing booking
       - Allow editing: guest name, phone, num guests, dates, optional fields
       - Room change allowed (with availability re-check)
       - Recalculate price on any change
       - Save button calls bookingRepository.updateBooking()
       - Pass excludeBookingId to isRoomAvailable() to allow same-date same-room for the booking being edited

    - Do NOT allow editing cancelled or completed bookings (navigate back with message)
    - MUST re-validate availability when dates or room change
    - MUST update the updatedAt timestamp on save
  </action>
  <verify>flutter analyze lib/features/bookings/presentation/edit_booking_screen.dart</verify>
  <done>Edit booking screen compiles, pre-populates data, re-validates availability, and saves changes</done>
</task>

<task type="auto">
  <name>Owner dashboard</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/dashboard/presentation/dashboard_screen.dart
  </files>
  <action>
    Replace placeholder dashboard with a full owner dashboard showing:
    1. Welcome header with owner name (from auth) and sign-out button
    2. Summary cards row:
       - "Today's Check-ins" count
       - "Today's Check-outs" count
       - "Occupied Rooms" count (rooms with active bookings covering today)
       - "Available Rooms" count
    3. Room status grid:
       - 5 room cards in a grid showing room name & current status
       - Color: green=available, orange=occupied, grey=checkout today
       - Tap to see room bookings
    4. Upcoming bookings section:
       - List of next 5 upcoming bookings (check-in after today)
       - Each shows guest name, room, dates
       - Tap to view booking detail
    5. Bottom navigation or drawer for:
       - Dashboard (home icon)
       - Bookings (list icon)
       - Rooms (bed icon)

    Design:
    - Gradient header with greeting
    - Summary cards with icons and subtle shadows
    - Modern card-based layout
    - Smooth animations for data loading

    - MUST call SeedData.seedRoomsIfEmpty() on dashboard first load
    - MUST use real-time streams (not one-time fetch)
    - Sign out button calls authRepository.signOut()
  </action>
  <verify>flutter analyze lib/features/dashboard/</verify>
  <done>Dashboard shows real-time room status, today's activity, upcoming bookings, and navigation</done>
</task>

## Success Criteria
- [ ] Edit screen pre-populates all booking data
- [ ] Edit re-validates room availability (excluding current booking)
- [ ] Dashboard shows today's check-ins/outs and room status
- [ ] Dashboard room cards show live availability
- [ ] Navigation to bookings list and rooms
- [ ] Seed data runs on first dashboard load
- [ ] `flutter analyze` passes
