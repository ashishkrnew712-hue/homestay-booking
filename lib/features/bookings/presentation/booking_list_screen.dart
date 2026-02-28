import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Screen showing a filterable list of all bookings.
class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({super.key});

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _filterBookings(List<Booking> bookings, int tabIndex) {
    switch (tabIndex) {
      case 1: // Active
        return bookings.where((b) => b.isActive).toList();
      case 2: // Cancelled
        return bookings
            .where((b) => b.status == BookingStatus.cancelled)
            .toList();
      default: // All
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookingsAsync = ref.watch(bookingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final filtered =
              _filterBookings(bookings, _tabController.index);
          if (filtered.isEmpty) {
            return _buildEmptyState(colorScheme);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _buildBookingCard(filtered[index], theme, colorScheme),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bookings/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first booking',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
      Booking booking, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/bookings/${booking.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        colorScheme.primaryContainer.withValues(alpha: 0.5),
                    child: Text(
                      booking.guestName.isNotEmpty
                          ? booking.guestName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.guestName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.roomName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(booking.status, colorScheme),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    AppDateUtils.formatDateRange(
                        booking.checkInDate, booking.checkOutDate),
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(Icons.people_outlined,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.numberOfGuests} guest(s)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '₹${booking.totalPrice.toInt()}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status, ColorScheme colorScheme) {
    final (Color bg, Color fg, String label) = switch (status) {
      BookingStatus.confirmed => (
          Colors.green.shade50,
          Colors.green.shade700,
          'Confirmed'
        ),
      BookingStatus.pending => (
          Colors.amber.shade50,
          Colors.amber.shade800,
          'Pending'
        ),
      BookingStatus.cancelled => (
          Colors.red.shade50,
          Colors.red.shade700,
          'Cancelled'
        ),
      BookingStatus.completed => (
          Colors.grey.shade100,
          Colors.grey.shade700,
          'Completed'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
