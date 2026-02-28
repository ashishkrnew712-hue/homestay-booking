import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';

/// Shows per-room availability and booking list for a selected day.
class DayBookingsSheet extends StatelessWidget {
  const DayBookingsSheet({
    super.key,
    required this.selectedDay,
    required this.bookings,
    required this.rooms,
  });

  final DateTime selectedDay;
  final List<Booking> bookings;
  final List<Room> rooms;

  /// Get bookings covering this day.
  List<Booking> get _dayBookings {
    final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    return bookings.where((b) {
      if (!b.isActive) return false;
      final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
      final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
      return !d.isBefore(ci) && d.isBefore(co);
    }).toList();
  }

  /// Check if a specific room is booked on this day.
  Booking? _bookingForRoom(String roomId) {
    final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    for (final b in bookings) {
      if (!b.isActive || b.roomId != roomId) continue;
      final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
      final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
      if (!d.isBefore(ci) && d.isBefore(co)) return b;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayBkgs = _dayBookings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text(
          AppDateUtils.formatFull(selectedDay),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${dayBkgs.length} booking(s) • ${rooms.length - dayBkgs.length} room(s) available',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // Room availability grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            final booking = _bookingForRoom(room.id);
            final isOccupied = booking != null;

            return InkWell(
              onTap: () {
                if (isOccupied) {
                  context.push('/bookings/${booking.id}');
                } else {
                  context.push('/bookings/create');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isOccupied ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOccupied
                        ? Colors.red.shade200
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOccupied ? Icons.bed : Icons.check_circle_outline,
                      color: isOccupied
                          ? Colors.red.shade400
                          : Colors.green.shade400,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isOccupied
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                    if (isOccupied)
                      Text(
                        booking.guestName.split(' ').first,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Bookings list
        if (dayBkgs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Bookings',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...dayBkgs.map((booking) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => context.push('/bookings/${booking.id}'),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      booking.roomName.split(' ').last,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(booking.guestName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${booking.roomName} • ${booking.numberOfGuests == 1 ? "Single" : "Double"} • ${AppDateUtils.formatDateRange(booking.checkInDate, booking.checkOutDate)}',
                  ),
                  trailing: Text(
                    '₹${booking.totalPrice.toInt()}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )),
        ] else ...[
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(Icons.event_available,
                    size: 40, color: colorScheme.outlineVariant),
                const SizedBox(height: 8),
                Text(
                  'All rooms available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
