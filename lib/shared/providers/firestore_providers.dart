import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestay_booking/features/rooms/data/room_repository.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/features/bookings/data/booking_repository.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';

/// Provider for Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for RoomRepository.
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepository(ref.watch(firestoreProvider));
});

/// Provider for BookingRepository.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(firestoreProvider));
});

/// Stream provider for all rooms.
final roomsStreamProvider = StreamProvider<List<Room>>((ref) {
  return ref.watch(roomRepositoryProvider).getRooms();
});

/// Stream provider for all bookings.
final bookingsStreamProvider = StreamProvider<List<Booking>>((ref) {
  return ref.watch(bookingRepositoryProvider).getBookings();
});

/// Stream provider for bookings of a specific room.
final roomBookingsProvider =
    StreamProvider.family<List<Booking>, String>((ref, roomId) {
  return ref.watch(bookingRepositoryProvider).getBookingsForRoom(roomId);
});
