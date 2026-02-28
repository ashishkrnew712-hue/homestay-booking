import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/core/utils/seed_data.dart';
import 'package:homestay_booking/core/services/notification_service.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/shared/providers/auth_provider.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Main dashboard for homestay owners.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedIfNeeded();
    NotificationService().initialize();
  }

  Future<void> _seedIfNeeded() async {
    if (_seeded) return;
    _seeded = true;
    final roomRepo = ref.read(roomRepositoryProvider);
    await SeedData(roomRepo).seedRoomsIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roomsAsync = ref.watch(roomsStreamProvider);
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            // Gradient header
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back 👋',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email?.split('@').first ?? 'Owner',
                                      style: GoogleFonts.outfit(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                                onPressed: () => _showSignOutDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Summary cards
                  bookingsAsync.when(
                    data: (bookings) => _buildSummaryCards(bookings, roomsAsync, colorScheme),
                    loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 20),

                  // Room status
                  Text('Room Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  roomsAsync.when(
                    data: (rooms) => bookingsAsync.when(
                      data: (bookings) => _buildRoomGrid(rooms, bookings, colorScheme),
                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 20),

                  // Upcoming bookings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Bookings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => context.go('/bookings'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  bookingsAsync.when(
                    data: (bookings) => _buildUpcomingBookings(bookings, theme, colorScheme),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bookings/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }

  Widget _buildSummaryCards(List<Booking> bookings, AsyncValue<List<Room>> roomsAsync, ColorScheme colorScheme) {
    final today = AppDateUtils.today();
    final tomorrow = today.add(const Duration(days: 1));

    final activeBookings = bookings.where((b) => b.isActive).toList();

    final todayCheckIns = activeBookings.where((b) {
      final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
      return ci.isAtSameMomentAs(today);
    }).length;

    final todayCheckOuts = activeBookings.where((b) {
      final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
      return co.isAtSameMomentAs(today) || co.isAtSameMomentAs(tomorrow);
    }).length;

    final occupiedRoomIds = activeBookings.where((b) {
      final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
      final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
      return !today.isBefore(ci) && today.isBefore(co);
    }).map((b) => b.roomId).toSet();

    final totalRooms = roomsAsync.value?.length ?? 5;
    final available = totalRooms - occupiedRoomIds.length;

    return Row(
      children: [
        Expanded(child: _summaryCard('Check-ins\nToday', '$todayCheckIns',
            Icons.login_rounded, Colors.blue, colorScheme)),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard('Check-outs\nToday', '$todayCheckOuts',
            Icons.logout_rounded, Colors.orange, colorScheme)),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard('Occupied', '${occupiedRoomIds.length}',
            Icons.bed, Colors.red, colorScheme)),
        const SizedBox(width: 8),
        Expanded(child: _summaryCard('Available', '$available',
            Icons.check_circle_outline, Colors.green, colorScheme)),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRoomGrid(List<Room> rooms, List<Booking> bookings, ColorScheme colorScheme) {
    final today = AppDateUtils.today();
    final activeBookings = bookings.where((b) => b.isActive).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isOccupied = activeBookings.any((b) {
          if (b.roomId != room.id) return false;
          final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
          final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
          return !today.isBefore(ci) && today.isBefore(co);
        });

        final checkoutToday = activeBookings.any((b) {
          if (b.roomId != room.id) return false;
          final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
          return co.isAtSameMomentAs(today);
        });

        Color cardColor;
        Color iconColor;
        String statusText;
        if (isOccupied) {
          cardColor = Colors.red.shade50;
          iconColor = Colors.red.shade400;
          statusText = 'Occupied';
        } else if (checkoutToday) {
          cardColor = Colors.orange.shade50;
          iconColor = Colors.orange.shade400;
          statusText = 'Checkout';
        } else {
          cardColor = Colors.green.shade50;
          iconColor = Colors.green.shade400;
          statusText = 'Available';
        }

        return InkWell(
          onTap: () {
            // Navigate to room bookings (future)
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bed_rounded, color: iconColor, size: 28),
                const SizedBox(height: 4),
                Text(room.name, style: TextStyle(fontWeight: FontWeight.w700, color: iconColor)),
                Text(statusText, style: TextStyle(fontSize: 10, color: iconColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingBookings(List<Booking> bookings, ThemeData theme, ColorScheme colorScheme) {
    final today = AppDateUtils.today();
    final upcoming = bookings
        .where((b) => b.isActive && b.checkInDate.isAfter(today))
        .take(5)
        .toList();

    if (upcoming.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.event_available, size: 40, color: colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Text('No upcoming bookings', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      children: upcoming.map((booking) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => context.push('/bookings/${booking.id}'),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(booking.roomName.split(' ').last,
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          title: Text(booking.guestName, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${booking.roomName} • ${AppDateUtils.formatDateRange(booking.checkInDate, booking.checkOutDate)}'),
          trailing: Text('₹${booking.totalPrice.toInt()}',
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700)),
        ),
      )).toList(),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authRepositoryProvider).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
