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
        name: 'Room 101',
        description: 'Ground floor double room',
        capacity: 2,
        pricePerNightSingle: 1500,
        pricePerNightDouble: 2000,
        weekendPricePerNightSingle: 1800,
        weekendPricePerNightDouble: 2400,
        amenities: ['Wi-Fi', 'Hot Water', 'Fan'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room 102',
        description: 'Ground floor room with garden view',
        capacity: 2,
        pricePerNightSingle: 1800,
        pricePerNightDouble: 2500,
        weekendPricePerNightSingle: 2160,
        weekendPricePerNightDouble: 3000,
        amenities: ['Wi-Fi', 'Hot Water', 'Fan', 'Patio'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room 103',
        description: 'Ground floor comfortable room',
        capacity: 2,
        pricePerNightSingle: 1500,
        pricePerNightDouble: 2000,
        weekendPricePerNightSingle: 1800,
        weekendPricePerNightDouble: 2400,
        amenities: ['Wi-Fi', 'Hot Water', 'Fan'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room 201',
        description: 'First floor peaceful room',
        capacity: 2,
        pricePerNightSingle: 2000,
        pricePerNightDouble: 2800,
        weekendPricePerNightSingle: 2400,
        weekendPricePerNightDouble: 3360,
        amenities: ['Wi-Fi', 'Hot Water', 'AC', 'Balcony'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room 202',
        description: 'First floor premium room with panoramic view',
        capacity: 2,
        pricePerNightSingle: 2200,
        pricePerNightDouble: 3000,
        weekendPricePerNightSingle: 2640,
        weekendPricePerNightDouble: 3600,
        amenities: ['Wi-Fi', 'Hot Water', 'AC', 'Balcony', 'Mini Fridge'],
        isActive: true,
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      ),
      Room(
        id: '',
        name: 'Room 203',
        description: 'First floor luxury suite',
        capacity: 2,
        pricePerNightSingle: 2500,
        pricePerNightDouble: 3500,
        weekendPricePerNightSingle: 3000,
        weekendPricePerNightDouble: 4200,
        amenities: ['Wi-Fi', 'Hot Water', 'AC', 'Balcony', 'Mini Fridge', 'TV'],
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
