---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: Pricing Engine & Room Settings

## Objective
Enhance pricing to support seasonal/weekend rates and make room pricing configurable from a settings screen. The booking creation and edit flows already handle single/double occupancy pricing — this plan adds the pricing engine layer and a room settings UI.

## Context
- .gsd/SPEC.md (Pricing section)
- lib/features/rooms/domain/room_model.dart
- lib/features/rooms/data/room_repository.dart
- lib/features/bookings/presentation/create_booking_screen.dart
- lib/features/bookings/presentation/edit_booking_screen.dart
- lib/core/constants/app_constants.dart

## Tasks

<task type="auto">
  <name>Pricing utility and room model enhancement</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/core/utils/pricing_utils.dart
    /home/ashish/MyProjects/Homestay/lib/features/rooms/domain/room_model.dart
  </files>
  <action>
    1. Create PricingUtils class with static methods:
       - calculateBookingPrice(Room room, DateTime checkIn, DateTime checkOut, int numberOfGuests)
         → Returns total price accounting for:
           - Single vs double occupancy rate
           - Weekend surcharge (Fri/Sat nights get a multiplier, e.g. 1.2x)
           - The per-night rate × number of nights
       - calculatePerNightRate(Room room, int numberOfGuests, DateTime date)
         → Returns rate for a specific night (handles weekend logic)
       - isWeekendNight(DateTime date) → bool (Friday and Saturday are weekend nights)

    2. Add weekend rate fields to Room model:
       - weekendPricePerNightSingle (double, defaults to pricePerNightSingle * 1.2)
       - weekendPricePerNightDouble (double, defaults to pricePerNightDouble * 1.2)
       - Update fromFirestore/toFirestore/copyWith accordingly
       - Update seed_data.dart to include weekend prices

    3. Update create_booking_screen.dart and edit_booking_screen.dart:
       - Replace _calculateTotalPrice() to use PricingUtils.calculateBookingPrice()
       - Update price summary to show breakdown per night (weekday vs weekend)

    - MUST be backward-compatible (existing Firestore docs without weekend fields should fallback gracefully)
    - Weekend surcharge should be visually indicated in price summary
  </action>
  <verify>flutter analyze lib/</verify>
  <done>Pricing utility calculates weekend-aware prices, Room model has weekend fields, booking screens use new pricing</done>
</task>

<task type="auto">
  <name>Room settings screen</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/rooms/presentation/room_settings_screen.dart
  </files>
  <action>
    Create RoomSettingsScreen for owners to edit room details:
    1. Edit room name and description
    2. Set weekday prices (single/double)
    3. Set weekend prices (single/double)
    4. Toggle amenities
    5. Save button updates Firestore via roomRepository.updateRoom()
    6. Navigate here from room list (tap edit icon or long press)

    Design:
    - Form with text fields and number inputs
    - Price fields with ₹ prefix
    - Amenities as editable chips (add/remove)
    - Consistent Material 3 styling

    - Do NOT allow changing room capacity (always 2 for MVP)
    - MUST validate prices are positive numbers
  </action>
  <verify>flutter analyze lib/features/rooms/</verify>
  <done>Room settings screen compiles, allows editing room details and pricing, saves to Firestore</done>
</task>

## Success Criteria
- [ ] PricingUtils correctly calculates weekend-aware pricing
- [ ] Room model supports weekday and weekend pricing
- [ ] Booking screens use PricingUtils for price calculations
- [ ] Room settings screen allows editing room prices
- [ ] `flutter analyze` passes
