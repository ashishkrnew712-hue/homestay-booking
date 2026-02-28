---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Calendar View

## Objective
Build a monthly calendar view showing room availability at a glance. Owners can see which rooms are booked on any given day, with color-coded indicators and the ability to tap a day to see its bookings.

## Context
- .gsd/SPEC.md (Calendar View section)
- lib/features/bookings/domain/booking_model.dart
- lib/features/bookings/data/booking_repository.dart
- lib/features/rooms/domain/room_model.dart
- lib/shared/providers/firestore_providers.dart
- pubspec.yaml (table_calendar dependency already added)

## Tasks

<task type="auto">
  <name>Calendar screen with room availability</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/calendar/presentation/calendar_screen.dart
  </files>
  <action>
    Create a CalendarScreen using the table_calendar package:
    1. Monthly calendar view (TableCalendar widget)
       - CalendarFormat.month as default
       - Allow switching to 2-week and week views
       - Highlight today
    2. Day markers showing booking density:
       - Green dot = some rooms available
       - Orange dot = partially booked
       - Red dot = fully booked (all 5 rooms occupied)
       - No dot = all rooms available
    3. On day tap — show bookings for that day below the calendar:
       - List of bookings for selected day (room name, guest name, check-in/out)
       - Show which rooms are available vs occupied
       - Tap a booking to navigate to BookingDetailScreen
    4. FAB to create booking (pre-fill selected date as check-in)
    5. Room filter — optional chip row above calendar to filter by specific room(s)

    Design:
    - Use table_calendar's CalendarStyle with Material 3 colors
    - Selected day has primary color highlight
    - Today has outline ring
    - Booking cards below calendar match existing card style
    - Smooth animation when switching months

    - MUST use real-time streams for bookings
    - MUST correctly determine if a booking covers a specific day (check-in ≤ day < check-out)
    - Do NOT use deprecated table_calendar APIs
  </action>
  <verify>flutter analyze lib/features/calendar/</verify>
  <done>Calendar screen compiles, shows monthly view with room availability dots, day selection shows filtered bookings</done>
</task>

<task type="auto">
  <name>Room availability detail for selected day</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/calendar/presentation/day_bookings_sheet.dart
  </files>
  <action>
    Create a DayBookingsSheet widget (used within CalendarScreen or as bottom sheet):
    1. Header showing selected date formatted
    2. Room availability grid:
       - Each room shown as a card
       - Green = available, Red = occupied (with guest name)
       - Tap occupied room → navigate to that booking
       - Tap available room → navigate to create booking (pre-fill room and date)
    3. List of all bookings that cover this day:
       - Guest name, room, check-in → check-out, occupancy
       - Status badge
       - Tap to view detail

    - MUST handle bookings that span multiple days correctly
    - A booking "covers" a day if checkIn ≤ day < checkOut
  </action>
  <verify>flutter analyze lib/features/calendar/</verify>
  <done>Day bookings sheet shows per-room availability and booking list for any selected day</done>
</task>

## Success Criteria
- [ ] Monthly calendar renders with correct booking markers
- [ ] Day tap shows room availability + bookings for that day
- [ ] Green/orange/red dots indicate booking density
- [ ] Navigation to booking detail and create booking works
- [ ] `flutter analyze` passes
