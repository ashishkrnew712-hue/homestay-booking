---
phase: 1
plan: 3
wave: 2
---

# Plan 1.3: Firestore Data Models & Seed Data

## Objective
Define Firestore data models for rooms and bookings, create repository classes, and seed the database with the 5 initial rooms.

## Context
- .gsd/SPEC.md (Rooms section, Booking Details section)
- .gsd/DECISIONS.md (ADR-004, ADR-006, ADR-007)
- lib/features/auth/data/auth_repository.dart (pattern to follow)

## Tasks

<task type="auto">
  <name>Room and Booking data models</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/features/rooms/domain/room_model.dart
    /home/ashish/MyProjects/Homestay/lib/features/bookings/domain/booking_model.dart
    /home/ashish/MyProjects/Homestay/lib/features/rooms/data/room_repository.dart
    /home/ashish/MyProjects/Homestay/lib/features/bookings/data/booking_repository.dart
  </files>
  <action>
    1. Create Room model:
       ```
       Room {
         id: String (Firestore doc ID)
         name: String ("A", "B", "C", "D", "E")
         description: String (optional)
         capacity: int (default: 2, double occupancy)
         pricePerNightSingle: double
         pricePerNightDouble: double
         amenities: List<String> (optional)
         imageUrl: String? (optional)
         isActive: bool (default: true)
         propertyId: String (for future multi-property)
         createdAt: DateTime
         updatedAt: DateTime
       }
       ```
    2. Create Booking model:
       ```
       Booking {
         id: String (Firestore doc ID)
         roomId: String (reference to room)
         roomName: String (denormalized for display)
         guestName: String (required)
         guestPhone: String (required)
         numberOfGuests: int (1 or 2, required)
         checkInDate: DateTime (required)
         checkOutDate: DateTime (required)
         idProof: String? (optional)
         specialRequests: String? (optional)
         addOns: List<String>? (optional — meals, activities)
         totalPrice: double
         status: BookingStatus (confirmed, cancelled, completed, pending)
         createdBy: String (owner UID who created)
         propertyId: String (for future multi-property)
         createdAt: DateTime
         updatedAt: DateTime
       }
       ```
    3. Create RoomRepository with Firestore CRUD:
       - getRooms() → Stream<List<Room>> (real-time)
       - getRoom(id) → Future<Room>
       - addRoom(room) → Future<void>
       - updateRoom(room) → Future<void>
    4. Create BookingRepository with Firestore CRUD:
       - getBookings() → Stream<List<Booking>> (real-time)
       - getBookingsForRoom(roomId) → Stream<List<Booking>>
       - getBookingsForDateRange(start, end) → Future<List<Booking>>
       - addBooking(booking) → Future<void>
       - updateBooking(booking) → Future<void>
       - cancelBooking(id) → Future<void>
    5. Create Riverpod providers for both repositories
    - Include fromFirestore/toFirestore serialization using json_serializable pattern
    - Include propertyId field in all models for future multi-property support
    - Do NOT use code generation (freezed/json_serializable) to keep it simple for MVP
    - Use manual fromMap/toMap methods instead
  </action>
  <verify>flutter analyze lib/features/rooms/ lib/features/bookings/</verify>
  <done>Room and Booking models compile, repositories have Firestore CRUD methods, providers are defined</done>
</task>

<task type="auto">
  <name>Seed initial room data</name>
  <files>
    /home/ashish/MyProjects/Homestay/lib/core/utils/seed_data.dart
  </files>
  <action>
    1. Create a seedRooms() function that:
       - Checks if rooms collection is empty
       - If empty, creates 5 rooms: A, B, C, D, E
       - Default pricing: configurable but start with reasonable defaults
       - Sets propertyId to "default" (single property for now)
    2. Call seedRooms() on first authenticated launch (in dashboard or app startup)
    - Only seed if rooms collection is empty (idempotent)
    - Do NOT hardcode prices — use reasonable defaults that owner can change later
  </action>
  <verify>flutter analyze lib/core/utils/seed_data.dart</verify>
  <done>Seed function creates 5 rooms in Firestore on first launch, skips if rooms exist</done>
</task>

## Success Criteria
- [ ] Room model has all fields from SPEC including propertyId for future
- [ ] Booking model has all mandatory and optional fields from SPEC
- [ ] Repositories use Firestore streams for real-time sync
- [ ] Seed function creates 5 rooms (A-E) on first run
- [ ] `flutter analyze` passes with no errors
