/// App-wide constants for the Homestay Booking app.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Homestay Booking';
  static const String appVersion = '1.0.0';

  // Property (single property for now)
  static const String defaultPropertyId = 'default';

  // Room defaults
  static const int defaultRoomCapacity = 2;
  static const int minGuests = 1;
  static const int maxGuests = 2;

  // Firestore collection names
  static const String roomsCollection = 'rooms';
  static const String bookingsCollection = 'bookings';
  static const String usersCollection = 'users';

  // Booking statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';
}
