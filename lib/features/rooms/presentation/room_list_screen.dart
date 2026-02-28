import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Screen showing all rooms with status and pricing.
class RoomListScreen extends ConsumerWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roomsAsync = ref.watch(roomsStreamProvider);
    final bookingsAsync = ref.watch(bookingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: roomsAsync.when(
        data: (rooms) => bookingsAsync.when(
          data: (bookings) => _buildRoomList(rooms, bookings, theme, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildRoomList(List<Room> rooms, List<Booking> bookings,
      ThemeData theme, ColorScheme colorScheme) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bed_outlined, size: 64, color: colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('No rooms found', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: rooms.length,
      itemBuilder: (context, index) =>
          _buildRoomCard(rooms[index], bookings, theme, colorScheme),
    );
  }

  Widget _buildRoomCard(Room room, List<Booking> bookings,
      ThemeData theme, ColorScheme colorScheme) {
    final today = AppDateUtils.today();
    final activeBookings = bookings.where((b) => b.isActive).toList();

    final isOccupied = activeBookings.any((b) {
      if (b.roomId != room.id) return false;
      final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
      final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
      return !today.isBefore(ci) && today.isBefore(co);
    });

    final currentBooking = isOccupied
        ? activeBookings.firstWhere((b) {
            if (b.roomId != room.id) return false;
            final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
            final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
            return !today.isBefore(ci) && today.isBefore(co);
          })
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bed_rounded,
                    color: isOccupied
                        ? Colors.red.shade400
                        : Colors.green.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        room.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOccupied ? 'Occupied' : 'Available',
                    style: TextStyle(
                      color: isOccupied
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pricing
            Row(
              children: [
                _priceChip('Single', '₹${room.pricePerNightSingle.toInt()}/night', colorScheme),
                const SizedBox(width: 8),
                _priceChip('Double', '₹${room.pricePerNightDouble.toInt()}/night', colorScheme),
              ],
            ),
            const SizedBox(height: 8),

            // Amenities
            if (room.amenities.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: room.amenities
                    .map((a) => Chip(
                          label: Text(a, style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ))
                    .toList(),
              ),

            // Current guest info
            if (currentBooking != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${currentBooking.guestName} • until ${AppDateUtils.formatShort(currentBooking.checkOutDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _priceChip(String label, String price, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
