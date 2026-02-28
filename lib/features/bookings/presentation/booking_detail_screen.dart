import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Screen showing full booking details with edit/cancel actions.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookingsAsync = ref.watch(bookingsStreamProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final booking = bookings.where((b) => b.id == bookingId).firstOrNull;
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking')),
            body: const Center(child: Text('Booking not found')),
          );
        }
        return _buildContent(context, ref, booking, theme, colorScheme);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Scaffold _buildContent(BuildContext context, WidgetRef ref, Booking booking,
      ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          if (booking.isActive)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/bookings/${booking.id}/edit'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status header
          _buildStatusHeader(booking, theme, colorScheme),
          const SizedBox(height: 20),

          // Guest info
          _buildInfoCard('Guest Information', Icons.person_outlined, [
            _infoRow('Name', booking.guestName),
            _infoRow('Phone', booking.guestPhone),
            _infoRow('Guests', '${booking.numberOfGuests} (${booking.numberOfGuests == 1 ? 'Single' : 'Double'} occupancy)'),
            if (booking.idProof != null && booking.idProof!.isNotEmpty)
              _infoRow('ID Proof', booking.idProof!),
          ], theme, colorScheme),
          const SizedBox(height: 12),

          // Room & dates
          _buildInfoCard('Stay Details', Icons.bed_outlined, [
            _infoRow('Room', booking.roomName),
            _infoRow('Check-in', AppDateUtils.formatFull(booking.checkInDate)),
            _infoRow('Check-out', AppDateUtils.formatFull(booking.checkOutDate)),
            _infoRow('Duration', '${booking.numberOfNights} night(s)'),
          ], theme, colorScheme),
          const SizedBox(height: 12),

          // Price
          _buildPriceCard(booking, theme, colorScheme),
          const SizedBox(height: 12),

          // Optional info
          if (booking.specialRequests != null &&
              booking.specialRequests!.isNotEmpty)
            ...[
              _buildInfoCard('Special Requests', Icons.note_outlined, [
                _infoRow('', booking.specialRequests!),
              ], theme, colorScheme),
              const SizedBox(height: 12),
            ],

          if (booking.addOns.isNotEmpty)
            ...[
              _buildInfoCard('Add-ons', Icons.room_service_outlined, [
                _infoRow('', booking.addOns.join(', ')),
              ], theme, colorScheme),
              const SizedBox(height: 12),
            ],

          // Metadata
          _buildInfoCard('Booking Info', Icons.info_outlined, [
            _infoRow('Created', AppDateUtils.formatFull(booking.createdAt)),
            _infoRow('Last Updated', AppDateUtils.formatFull(booking.updatedAt)),
            _infoRow('Booking ID', booking.id),
          ], theme, colorScheme),
          const SizedBox(height: 24),

          // Cancel button
          if (booking.isActive)
            OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context, ref, booking),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Booking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(
      Booking booking, ThemeData theme, ColorScheme colorScheme) {
    final (Color bg, Color fg, IconData icon) = switch (booking.status) {
      BookingStatus.confirmed => (
          Colors.green.shade50,
          Colors.green.shade700,
          Icons.check_circle_outlined
        ),
      BookingStatus.pending => (
          Colors.amber.shade50,
          Colors.amber.shade800,
          Icons.hourglass_empty
        ),
      BookingStatus.cancelled => (
          Colors.red.shade50,
          Colors.red.shade700,
          Icons.cancel_outlined
        ),
      BookingStatus.completed => (
          Colors.grey.shade100,
          Colors.grey.shade700,
          Icons.task_alt
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.status.name.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${booking.roomName} • ${AppDateUtils.formatDateRange(booking.checkInDate, booking.checkOutDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: fg),
                ),
              ],
            ),
          ),
          Text(
            '₹${booking.totalPrice.toInt()}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon,
      List<Widget> children, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(
      Booking booking, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payments_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Price Breakdown',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _infoRow('Occupancy',
                booking.numberOfGuests == 1 ? 'Single' : 'Double'),
            _infoRow('Nights', '${booking.numberOfNights}'),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('₹${booking.totalPrice.toInt()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
            'Cancel booking for ${booking.guestName} in ${booking.roomName}?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(bookingRepositoryProvider)
                    .cancelBooking(booking.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}
