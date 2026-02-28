# SPEC.md — Project Specification

> **Status**: `FINALIZED`

## Vision
A modern, Flutter-based mobile app for managing homestay room bookings across Android and iOS. Two co-owners manage a 5-room property and need real-time sync to avoid double bookings and miscommunication. The app replaces WhatsApp-based coordination with a dedicated booking management system powered by Firebase.

## Goals
1. **Real-time booking sync** — Both owners see the same booking state instantly, eliminating double bookings
2. **Room availability at a glance** — Calendar view showing which rooms are booked, available, or blocked
3. **Guest information management** — Capture and retrieve guest details (name, phone, ID proof, guest count, dates, special requests)
4. **Flexible pricing** — Support seasonal rates, weekday/weekend pricing, single vs double occupancy
5. **Push notifications** — Notify the other owner instantly when a booking is created, modified, or cancelled

## Non-Goals (Out of Scope)
- Guest-facing booking portal (future enhancement)
- Online payment processing (UPI payments handled offline)
- OTA integration (Airbnb, Booking.com, etc.)
- Multi-property management (future enhancement)
- Analytics or revenue reporting (future enhancement)

## Users
- **Owner A & Owner B** — Equal access, full control over all bookings and room management. Both authenticate separately and receive push notifications for all booking changes.

## Rooms
- **5 rooms**: A, B, C, D, E (placeholder names, configurable later)
- **All double occupancy** — can accommodate 1 or 2 guests
- **Per-room pricing** — each room can have different base rates
- **Occupancy-based pricing** — single occupancy should have a different (likely lower) rate than double

## Booking Details
**Mandatory fields:**
- Guest name
- Phone number
- Number of guests (1 or 2)
- Check-in date
- Check-out date

**Optional fields:**
- ID proof (photo/number)
- Special requests
- Add-ons (meals, activities)

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend/Database**: Firebase (Firestore, Auth, Cloud Messaging)
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Platform**: Android + iOS

## Constraints
- **Timeline**: MVP by end of weekend (Feb 28 – Mar 2, 2026)
- **Team**: Solo developer with AI assistance
- **Scale**: Single property, 5 rooms, 2 owners
- **Offline payments**: No payment gateway integration needed

## Success Criteria
- [ ] Both owners can log in with separate accounts
- [ ] All 5 rooms visible with availability status
- [ ] Bookings can be created, viewed, edited, and cancelled
- [ ] Real-time sync — changes appear on both devices instantly
- [ ] Push notifications fire when bookings change
- [ ] Calendar view shows room availability at a glance
- [ ] Single vs double occupancy pricing works correctly
