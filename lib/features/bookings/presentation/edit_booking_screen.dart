import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Screen for editing an existing booking.
class EditBookingScreen extends ConsumerStatefulWidget {
  const EditBookingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends ConsumerState<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _idProofController = TextEditingController();
  final _specialRequestsController = TextEditingController();

  Room? _selectedRoom;
  int _numberOfGuests = 2;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final List<String> _selectedAddOns = [];
  bool _isLoading = false;
  bool _initialized = false;
  String? _availabilityError;

  final List<String> _availableAddOns = [
    'Breakfast', 'Lunch', 'Dinner', 'Campfire', 'Trekking', 'Sightseeing',
  ];

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _idProofController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _initFromBooking(Booking booking, List<Room> rooms) {
    if (_initialized) return;
    _guestNameController.text = booking.guestName;
    _guestPhoneController.text = booking.guestPhone;
    _idProofController.text = booking.idProof ?? '';
    _specialRequestsController.text = booking.specialRequests ?? '';
    _numberOfGuests = booking.numberOfGuests;
    _checkInDate = booking.checkInDate;
    _checkOutDate = booking.checkOutDate;
    _selectedAddOns.addAll(booking.addOns);
    _selectedRoom = rooms.where((r) => r.id == booking.roomId).firstOrNull;
    _initialized = true;
  }

  double _calculateTotalPrice() {
    if (_selectedRoom == null || _checkInDate == null || _checkOutDate == null) return 0;
    final nights = AppDateUtils.calculateNights(_checkInDate!, _checkOutDate!);
    if (nights <= 0) return 0;
    final rate = _numberOfGuests == 1
        ? _selectedRoom!.pricePerNightSingle
        : _selectedRoom!.pricePerNightDouble;
    return rate * nights;
  }

  Future<void> _selectDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final firstDate = isCheckIn ? now : (_checkInDate ?? now).add(const Duration(days: 1));
    final initialDate = isCheckIn
        ? (_checkInDate ?? now)
        : (_checkOutDate ?? firstDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && !_checkOutDate!.isAfter(picked)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
        _availabilityError = null;
      });
    }
  }

  Future<void> _saveBooking(Booking original) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null || _checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() { _isLoading = true; _availabilityError = null; });

    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);

      // Check availability (exclude current booking)
      final isAvailable = await bookingRepo.isRoomAvailable(
        _selectedRoom!.id, _checkInDate!, _checkOutDate!,
        excludeBookingId: original.id,
      );

      if (!isAvailable) {
        setState(() {
          _availabilityError = '${_selectedRoom!.name} is already booked for these dates.';
          _isLoading = false;
        });
        return;
      }

      final updated = original.copyWith(
        roomId: _selectedRoom!.id,
        roomName: _selectedRoom!.name,
        guestName: _guestNameController.text.trim(),
        guestPhone: _guestPhoneController.text.trim(),
        numberOfGuests: _numberOfGuests,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        idProof: _idProofController.text.trim().isNotEmpty
            ? _idProofController.text.trim()
            : null,
        specialRequests: _specialRequestsController.text.trim().isNotEmpty
            ? _specialRequestsController.text.trim()
            : null,
        addOns: List<String>.from(_selectedAddOns),
        totalPrice: _calculateTotalPrice(),
        updatedAt: DateTime.now(),
      );

      await bookingRepo.updateBooking(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking updated'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final roomsAsync = ref.watch(roomsStreamProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final booking = bookings.where((b) => b.id == widget.bookingId).firstOrNull;
        if (booking == null || !booking.isActive) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Booking')),
            body: const Center(child: Text('Booking cannot be edited')),
          );
        }
        return roomsAsync.when(
          data: (rooms) {
            _initFromBooking(booking, rooms);
            return _buildForm(booking, rooms, theme, colorScheme);
          },
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Edit Booking')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Edit Booking')),
            body: Center(child: Text('Error: $e')),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit Booking')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Booking')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Scaffold _buildForm(Booking booking, List<Room> rooms, ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Booking')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Room
            DropdownButtonFormField<Room>(
              initialValue: _selectedRoom,
              decoration: const InputDecoration(
                labelText: 'Room *', prefixIcon: Icon(Icons.bed_outlined),
              ),
              items: rooms.map((room) {
                final price = _numberOfGuests == 1
                    ? room.pricePerNightSingle : room.pricePerNightDouble;
                return DropdownMenuItem(value: room,
                    child: Text('${room.name} — ₹${price.toInt()}/night'));
              }).toList(),
              onChanged: (r) => setState(() { _selectedRoom = r; _availabilityError = null; }),
              validator: (v) => v == null ? 'Select a room' : null,
            ),
            const SizedBox(height: 12),

            // Guest name
            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(
                  labelText: 'Guest Name *', prefixIcon: Icon(Icons.person_outlined)),
              textCapitalization: TextCapitalization.words,
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Phone
            TextFormField(
              controller: _guestPhoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone *', prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 10) return 'Enter valid phone';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Guests
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Single (1)'), icon: Icon(Icons.person)),
                ButtonSegment(value: 2, label: Text('Double (2)'), icon: Icon(Icons.people)),
              ],
              selected: {_numberOfGuests},
              onSelectionChanged: (s) => setState(() => _numberOfGuests = s.first),
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(child: _dateTile('Check-in', _checkInDate, true, colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _dateTile('Check-out', _checkOutDate, false, colorScheme)),
              ],
            ),

            if (_availabilityError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_availabilityError!, style: TextStyle(color: colorScheme.onErrorContainer))),
                ]),
              ),
            ],
            const SizedBox(height: 16),

            // Optional
            TextFormField(
              controller: _idProofController,
              decoration: const InputDecoration(
                  labelText: 'ID Proof', prefixIcon: Icon(Icons.badge_outlined)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _specialRequestsController,
              decoration: const InputDecoration(
                  labelText: 'Special Requests', prefixIcon: Icon(Icons.note_outlined)),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // Add-ons
            Wrap(
              spacing: 8, runSpacing: 4,
              children: _availableAddOns.map((a) => FilterChip(
                label: Text(a),
                selected: _selectedAddOns.contains(a),
                onSelected: (s) => setState(() {
                  s ? _selectedAddOns.add(a) : _selectedAddOns.remove(a);
                }),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // Price
            if (_selectedRoom != null && _checkInDate != null && _checkOutDate != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('₹${_calculateTotalPrice().toInt()}',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: colorScheme.primary)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Save
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _saveBooking(booking),
                icon: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, bool isCheckIn, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _selectDate(isCheckIn: isCheckIn),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(date != null ? AppDateUtils.formatDisplay(date) : 'Select',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: date != null ? FontWeight.w600 : FontWeight.normal)),
          ]),
        ]),
      ),
    );
  }
}
