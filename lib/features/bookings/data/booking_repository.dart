import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homestay_booking/core/constants/app_constants.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';

/// Repository for Booking CRUD operations with Firestore.
class BookingRepository {
  BookingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection(AppConstants.bookingsCollection);

  /// Stream of all bookings (real-time).
  Stream<List<Booking>> getBookings() {
    return _bookingsRef
        .where('propertyId', isEqualTo: AppConstants.defaultPropertyId)
        .orderBy('checkInDate', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  /// Stream of bookings for a specific room.
  Stream<List<Booking>> getBookingsForRoom(String roomId) {
    return _bookingsRef
        .where('roomId', isEqualTo: roomId)
        .where('propertyId', isEqualTo: AppConstants.defaultPropertyId)
        .orderBy('checkInDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  /// Get bookings within a date range.
  Future<List<Booking>> getBookingsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _bookingsRef
        .where('propertyId', isEqualTo: AppConstants.defaultPropertyId)
        .where('checkInDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    return snapshot.docs
        .map((doc) => Booking.fromFirestore(doc))
        .where((booking) =>
            booking.checkOutDate.isAfter(start) && booking.isActive)
        .toList();
  }

  /// Add a new booking.
  Future<String> addBooking(Booking booking) async {
    final docRef = await _bookingsRef.add(booking.toFirestore());
    return docRef.id;
  }

  /// Update an existing booking.
  Future<void> updateBooking(Booking booking) async {
    await _bookingsRef.doc(booking.id).update(booking.toFirestore());
  }

  /// Cancel a booking (sets status to cancelled).
  Future<void> cancelBooking(String id) async {
    await _bookingsRef.doc(id).update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Check if a room is available for a given date range.
  /// Returns true if no active bookings overlap the range.
  Future<bool> isRoomAvailable(
    String roomId,
    DateTime checkIn,
    DateTime checkOut, {
    String? excludeBookingId,
  }) async {
    final snapshot = await _bookingsRef
        .where('roomId', isEqualTo: roomId)
        .where('propertyId', isEqualTo: AppConstants.defaultPropertyId)
        .get();

    final overlapping = snapshot.docs
        .map((doc) => Booking.fromFirestore(doc))
        .where((booking) {
      if (!booking.isActive) return false;
      if (excludeBookingId != null && booking.id == excludeBookingId) {
        return false;
      }
      // Check for overlap: bookings overlap if start1 < end2 AND start2 < end1
      final s1 = DateTime(checkIn.year, checkIn.month, checkIn.day);
      final e1 = DateTime(checkOut.year, checkOut.month, checkOut.day);
      final s2 = DateTime(
          booking.checkInDate.year, booking.checkInDate.month, booking.checkInDate.day);
      final e2 = DateTime(
          booking.checkOutDate.year, booking.checkOutDate.month, booking.checkOutDate.day);
      return s1.isBefore(e2) && s2.isBefore(e1);
    });

    return overlapping.isEmpty;
  }
}
