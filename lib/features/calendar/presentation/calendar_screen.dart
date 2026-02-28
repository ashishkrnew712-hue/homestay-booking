import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/features/calendar/presentation/day_bookings_sheet.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Monthly calendar view showing room availability at a glance.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = AppDateUtils.today();
  }

  /// Determine how many rooms are booked on a given day.
  int _bookedRoomCount(DateTime day, List<Booking> bookings) {
    final d = DateTime(day.year, day.month, day.day);
    final occupiedRoomIds = <String>{};
    for (final b in bookings) {
      if (!b.isActive) continue;
      final ci = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
      final co = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
      if (!d.isBefore(ci) && d.isBefore(co)) {
        occupiedRoomIds.add(b.roomId);
      }
    }
    return occupiedRoomIds.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final roomsAsync = ref.watch(roomsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: bookingsAsync.when(
        data: (bookings) => roomsAsync.when(
          data: (rooms) => _buildBody(bookings, rooms, theme, colorScheme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final dateParam = _selectedDay != null
              ? '?date=${_selectedDay!.toIso8601String()}'
              : '';
          context.push('/bookings/create$dateParam');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }

  Widget _buildBody(List<Booking> bookings, List<Room> rooms,
      ThemeData theme, ColorScheme colorScheme) {
    final totalRooms = rooms.length;

    return Column(
      children: [
        // Calendar
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
            ),
            todayTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600),
            markerDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
            outsideDaysVisible: false,
          ),
          headerStyle: HeaderStyle(
            formatButtonDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            formatButtonTextStyle: theme.textTheme.bodySmall!,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final bookedCount = _bookedRoomCount(date, bookings);
              if (bookedCount == 0) return null;

              Color dotColor;
              if (bookedCount >= totalRooms) {
                dotColor = Colors.red.shade400;
              } else if (bookedCount >= (totalRooms / 2).ceil()) {
                dotColor = Colors.orange.shade400;
              } else {
                dotColor = Colors.green.shade400;
              }

              return Positioned(
                bottom: 1,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),

        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(Colors.green.shade400, 'Available'),
              const SizedBox(width: 16),
              _legendDot(Colors.orange.shade400, 'Partial'),
              const SizedBox(width: 16),
              _legendDot(Colors.red.shade400, 'Full'),
            ],
          ),
        ),

        const Divider(height: 1),

        // Day detail
        Expanded(
          child: _selectedDay != null
              ? DayBookingsSheet(
                  selectedDay: _selectedDay!,
                  bookings: bookings,
                  rooms: rooms,
                )
              : Center(
                  child: Text(
                    'Select a day to see bookings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
