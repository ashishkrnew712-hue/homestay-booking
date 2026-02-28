import 'package:homestay_booking/core/constants/app_constants.dart';
import 'package:homestay_booking/features/rooms/data/room_repository.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';

/// Seeds the Firestore database with initial room data.
/// Only runs if the rooms collection is empty (idempotent).
class SeedData {
  SeedData(this._roomRepository);

  final RoomRepository _roomRepository;

  /// Seed initial rooms. Safe to call multiple times.
  Future<void> seedRoomsIfEmpty() async {
    final hasRooms = await _roomRepository.hasRooms();
    if (hasRooms) return; // Already seeded

    final now = DateTime.now();
    final rooms = [
      Room(
        id: '',
        name: 'Room A',
        description: 'Cozy double room with garden view',
        capacity: 2,
        pricePerNightSingle: 1500,
        pricePerNightDouble: 2000,
        amenities: ['Wi-Fi', 'Hot Water', 'Fan'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room B',
        description: 'Spacious room with mountain view',
        capacity: 2,
        pricePerNightSingle: 1800,
        pricePerNightDouble: 2500,
        amenities: ['Wi-Fi', 'Hot Water', 'Fan', 'Balcony'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room C',
        description: 'Comfortable room with attached bathroom',
        capacity: 2,
        pricePerNightSingle: 1500,
        pricePerNightDouble: 2000,
        amenities: ['Wi-Fi', 'Hot Water', 'Fan'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room D',
        description: 'Peaceful room with forest view',
        capacity: 2,
        pricePerNightSingle: 2000,
        pricePerNightDouble: 2800,
        amenities: ['Wi-Fi', 'Hot Water', 'AC', 'Balcony'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room E',
        description: 'Premium room with panoramic view',
        capacity: 2,
        pricePerNightSingle: 2200,
        pricePerNightDouble: 3000,
        amenities: ['Wi-Fi', 'Hot Water', 'AC', 'Balcony', 'Mini Fridge'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final room in rooms) {
      await _roomRepository.addRoom(room);
    }
  }
}
