---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Booking Creation Flow

## Objective
Build the complete booking creation flow: a form screen where owners can select a room, enter guest details, pick dates, and create a booking with real-time availability validation.

## Context
- .gsd/SPEC.md (Booking Details section)
- lib/features/bookings/domain/booking_model.dart
- lib/features/bookings/data/booking_repository.dart
- lib/features/rooms/domain/room_model.dart
- lib/shared/providers/firestore_providers.dart
- lib/shared/providers/auth_provider.dart

## Tasks

<task type="auto">
  <name>Create booking form screen</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/bookings/presentation/create_booking_screen.dart
  </files>
  <action>
    Create a full-featured booking creation screen with:
    1. Room selector dropdown (populated from Firestore rooms stream)
    2. Guest name field (required, text input)
    3. Guest phone field (required, phone keyboard)
    4. Number of guests selector (1 or 2, segmented button or toggle)
    5. Check-in date picker (DatePicker, cannot be in the past)
    6. Check-out date picker (must be after check-in)
    7. Optional fields section (expandable):
       - ID proof (text field)
       - Special requests (multiline text)
       - Add-ons (chips: Breakfast, Lunch, Dinner, Activities)
    8. Price display (auto-calculated based on room, occupancy, and nights)
    9. Create booking button with loading state
    10. Availability check before creation — show error if room is booked for those dates

    Design:
    - Use Material 3 components (filled text fields, segmented buttons, date pickers)
    - Consistent with login screen aesthetic
    - Scrollable form with section headers
    - Show total price breakdown before confirming

    - Do NOT allow check-in date in the past
    - Do NOT allow check-out before or equal to check-in
    - MUST check room availability via BookingRepository.isRoomAvailable() before creating
    - MUST set createdBy to current user UID
    - MUST set propertyId to AppConstants.defaultPropertyId
  </action>
  <verify>flutter analyze lib/features/bookings/presentation/create_booking_screen.dart</verify>
  <done>Booking form screen compiles with all fields, validation, availability check, and price calculation</done>
</task>

<task type="auto">
  <name>Booking list and detail screens</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/bookings/presentation/booking_list_screen.dart
    /home/ashish/MyProjects/Homestay/lib/features/bookings/presentation/booking_detail_screen.dart
  </files>
  <action>
    1. BookingListScreen:
       - Real-time list of all bookings via bookingsStreamProvider
       - Filter tabs: All | Active | Cancelled
       - Each card shows: guest name, room name, dates, occupancy, status badge
       - Tap to navigate to BookingDetailScreen
       - FAB to create new booking
       - Empty state when no bookings
       - Color-coded status badges (green=confirmed, yellow=pending, red=cancelled, grey=completed)

    2. BookingDetailScreen:
       - Full booking info display (all mandatory + optional fields)
       - Status badge
       - Price breakdown (nights × rate)
       - Action buttons: Edit, Cancel (with confirmation dialog)
       - Cancel sets status to cancelled via bookingRepository.cancelBooking()
       - Show "Created by" info

    - Do NOT allow editing cancelled or completed bookings
    - Cancel action MUST show confirmation dialog before proceeding
  </action>
  <verify>flutter analyze lib/features/bookings/presentation/</verify>
  <done>Booking list with filter tabs and detail screen with edit/cancel actions compile successfully</done>
</task>

## Success Criteria
- [ ] Booking form has all mandatory and optional fields
- [ ] Availability check prevents double bookings
- [ ] Price auto-calculates based on room, occupancy, and nights
- [ ] Booking list shows real-time data with filter tabs
- [ ] Booking detail shows full info with cancel action
- [ ] `flutter analyze` passes
