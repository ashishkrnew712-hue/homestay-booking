import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a room in the homestay property.
class Room {
  Room({
    required this.id,
    required this.name,
    this.description = '',
    this.capacity = 2,
    required this.pricePerNightSingle,
    required this.pricePerNightDouble,
    this.amenities = const [],
    this.imageUrl,
    this.isActive = true,
    required this.propertyId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final int capacity;
  final double pricePerNightSingle;
  final double pricePerNightDouble;
  final List<String> amenities;
  final String? imageUrl;
  final bool isActive;
  final String propertyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Create Room from Firestore document.
  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      capacity: data['capacity'] ?? 2,
      pricePerNightSingle: (data['pricePerNightSingle'] ?? 0).toDouble(),
      pricePerNightDouble: (data['pricePerNightDouble'] ?? 0).toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      propertyId: data['propertyId'] ?? 'default',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Room to Firestore map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'capacity': capacity,
      'pricePerNightSingle': pricePerNightSingle,
      'pricePerNightDouble': pricePerNightDouble,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'propertyId': propertyId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields.
  Room copyWith({
    String? name,
    String? description,
    int? capacity,
    double? pricePerNightSingle,
    double? pricePerNightDouble,
    List<String>? amenities,
    String? imageUrl,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      pricePerNightSingle: pricePerNightSingle ?? this.pricePerNightSingle,
      pricePerNightDouble: pricePerNightDouble ?? this.pricePerNightDouble,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      propertyId: propertyId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
