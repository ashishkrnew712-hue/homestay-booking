import 'package:intl/intl.dart';

/// Date utility functions for the booking system.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _fullDate = DateFormat('EEEE, dd MMMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Format date for display: "28 Feb 2026"
  static String formatDisplay(DateTime date) => _displayDate.format(date);

  /// Format date short: "28 Feb"
  static String formatShort(DateTime date) => _shortDate.format(date);

  /// Format day month: "28 Feb"
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);

  /// Format full date: "Saturday, 28 February 2026"
  static String formatFull(DateTime date) => _fullDate.format(date);

  /// Format time: "07:30 AM"
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Format date range: "28 Feb - 02 Mar"
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${formatShort(end)}';
    }
    return '${formatShort(start)} - ${formatShort(end)}';
  }

  /// Calculate number of nights between two dates.
  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    final checkInDate = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final checkOutDate = DateTime(checkOut.year, checkOut.month, checkOut.day);
    return checkOutDate.difference(checkInDate).inDays;
  }

  /// Check if a date falls within a range (inclusive).
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Check if two date ranges overlap.
  static bool doRangesOverlap(
    DateTime start1, DateTime end1,
    DateTime start2, DateTime end2,
  ) {
    final s1 = DateTime(start1.year, start1.month, start1.day);
    final e1 = DateTime(end1.year, end1.month, end1.day);
    final s2 = DateTime(start2.year, start2.month, start2.day);
    final e2 = DateTime(end2.year, end2.month, end2.day);
    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  /// Get today's date with time stripped.
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is in the past.
  static bool isPast(DateTime date) {
    return DateTime(date.year, date.month, date.day).isBefore(today());
  }

  /// Check if a given date is a weekend (Saturday or Sunday).
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }
}
