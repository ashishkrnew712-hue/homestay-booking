import 'package:cloud_firestore/cloud_firestore.dart';

/// Possible booking statuses.
enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  /// Convert string to BookingStatus.
  static BookingStatus fromString(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Represents a booking in the homestay.
class Booking {
  Booking({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.guestName,
    required this.guestPhone,
    required this.numberOfGuests,
    required this.checkInDate,
    required this.checkOutDate,
    this.idProof,
    this.specialRequests,
    this.addOns = const [],
    required this.totalPrice,
    this.status = BookingStatus.confirmed,
    required this.createdBy,
    required this.propertyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String roomId;
  final String roomName; // denormalized for display
  final String guestName;
  final String guestPhone;
  final int numberOfGuests; // 1 or 2
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String? idProof;
  final String? specialRequests;
  final List<String> addOns;
  final double totalPrice;
  final BookingStatus status;
  final String createdBy; // owner UID
  final String propertyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Number of nights for this booking.
  int get numberOfNights {
    final checkIn = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final checkOut = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    return checkOut.difference(checkIn).inDays;
  }

  /// Whether the booking is active (not cancelled or completed).
  bool get isActive =>
      status == BookingStatus.confirmed || status == BookingStatus.pending;

  /// Create Booking from Firestore document.
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      roomId: data['roomId'] ?? '',
      roomName: data['roomName'] ?? '',
      guestName: data['guestName'] ?? '',
      guestPhone: data['guestPhone'] ?? '',
      numberOfGuests: data['numberOfGuests'] ?? 1,
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      idProof: data['idProof'],
      specialRequests: data['specialRequests'],
      addOns: List<String>.from(data['addOns'] ?? []),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      status: BookingStatus.fromString(data['status'] ?? 'pending'),
      createdBy: data['createdBy'] ?? '',
      propertyId: data['propertyId'] ?? 'default',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Booking to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'guestName': guestName,
      'guestPhone': guestPhone,
      'numberOfGuests': numberOfGuests,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'idProof': idProof,
      'specialRequests': specialRequests,
      'addOns': addOns,
      'totalPrice': totalPrice,
      'status': status.name,
      'createdBy': createdBy,
      'propertyId': propertyId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields.
  Booking copyWith({
    String? roomId,
    String? roomName,
    String? guestName,
    String? guestPhone,
    int? numberOfGuests,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? idProof,
    String? specialRequests,
    List<String>? addOns,
    double? totalPrice,
    BookingStatus? status,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      idProof: idProof ?? this.idProof,
      specialRequests: specialRequests ?? this.specialRequests,
      addOns: addOns ?? this.addOns,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdBy: createdBy,
      propertyId: propertyId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
