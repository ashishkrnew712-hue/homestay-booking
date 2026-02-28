import 'package:homestay_booking/features/rooms/domain/room_model.dart';

/// Utility class for booking price calculations.
class PricingUtils {
  PricingUtils._();

  /// Whether a given night is a weekend night (Friday or Saturday).
  /// The "night" of a date means the guest stays that night.
  /// Friday night = check-in Friday, Saturday night = check-in Saturday.
  static bool isWeekendNight(DateTime date) {
    // DateTime.friday = 5, DateTime.saturday = 6
    return date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
  }

  /// Get the per-night rate for a specific date.
  static double getPerNightRate(Room room, int numberOfGuests, DateTime date) {
    final isWeekend = isWeekendNight(date);
    if (numberOfGuests == 1) {
      return isWeekend
          ? room.weekendPricePerNightSingle
          : room.pricePerNightSingle;
    } else {
      return isWeekend
          ? room.weekendPricePerNightDouble
          : room.pricePerNightDouble;
    }
  }

  /// Calculate the total booking price across all nights.
  /// Each night from checkIn to checkOut-1 is priced individually.
  static double calculateBookingPrice(
    Room room,
    DateTime checkIn,
    DateTime checkOut,
    int numberOfGuests,
  ) {
    final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final end = DateTime(checkOut.year, checkOut.month, checkOut.day);
    double total = 0;
    var current = start;
    while (current.isBefore(end)) {
      total += getPerNightRate(room, numberOfGuests, current);
      current = current.add(const Duration(days: 1));
    }
    return total;
  }

  /// Get a breakdown of pricing per night (for display).
  /// Returns list of (date, rate, isWeekend) tuples.
  static List<({DateTime date, double rate, bool isWeekend})> getPriceBreakdown(
    Room room,
    DateTime checkIn,
    DateTime checkOut,
    int numberOfGuests,
  ) {
    final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final end = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final breakdown = <({DateTime date, double rate, bool isWeekend})>[];
    var current = start;
    while (current.isBefore(end)) {
      final isWeekend = isWeekendNight(current);
      final rate = getPerNightRate(room, numberOfGuests, current);
      breakdown.add((date: current, rate: rate, isWeekend: isWeekend));
      current = current.add(const Duration(days: 1));
    }
    return breakdown;
  }

  /// Count weekday and weekend nights in a range.
  static ({int weekday, int weekend}) countNightTypes(
    DateTime checkIn,
    DateTime checkOut,
  ) {
    final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final end = DateTime(checkOut.year, checkOut.month, checkOut.day);
    int weekday = 0, weekend = 0;
    var current = start;
    while (current.isBefore(end)) {
      if (isWeekendNight(current)) {
        weekend++;
      } else {
        weekday++;
      }
      current = current.add(const Duration(days: 1));
    }
    return (weekday: weekday, weekend: weekend);
  }
}
