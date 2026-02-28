import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homestay_booking/core/constants/app_constants.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';

/// Repository for Room CRUD operations with Firestore.
class RoomRepository {
  RoomRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      _firestore.collection(AppConstants.roomsCollection);

  /// Stream of all active rooms (real-time).
  Stream<List<Room>> getRooms() {
    return _roomsRef
        .where('propertyId', isEqualTo: AppConstants.defaultPropertyId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }

  /// Get a single room by ID.
  Future<Room?> getRoom(String id) async {
    final doc = await _roomsRef.doc(id).get();
    if (!doc.exists) return null;
    return Room.fromFirestore(doc);
  }

  /// Add a new room.
  Future<String> addRoom(Room room) async {
    final docRef = await _roomsRef.add(room.toFirestore());
    return docRef.id;
  }

  /// Update an existing room.
  Future<void> updateRoom(Room room) async {
    await _roomsRef.doc(room.id).update(room.toFirestore());
  }

  /// Check if any rooms exist.
  Future<bool> hasRooms() async {
    final snapshot = await _roomsRef
        .where('propertyId', isEqualTo: AppConstants.defaultPropertyId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
