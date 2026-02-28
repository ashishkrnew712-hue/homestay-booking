import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestay_booking/core/constants/app_constants.dart';
import 'package:homestay_booking/core/utils/date_utils.dart';
import 'package:homestay_booking/features/bookings/domain/booking_model.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/shared/providers/auth_provider.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Screen for creating a new booking.
class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
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
  bool _showOptionalFields = false;
  String? _availabilityError;

  final List<String> _availableAddOns = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Campfire',
    'Trekking',
    'Sightseeing',
  ];

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _idProofController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice() {
    if (_selectedRoom == null || _checkInDate == null || _checkOutDate == null) {
      return 0;
    }
    final nights = AppDateUtils.calculateNights(_checkInDate!, _checkOutDate!);
    if (nights <= 0) return 0;
    final ratePerNight = _numberOfGuests == 1
        ? _selectedRoom!.pricePerNightSingle
        : _selectedRoom!.pricePerNightDouble;
    return ratePerNight * nights;
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
          // Reset check-out if it's before or equal to new check-in
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

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null || _checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select room and dates')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _availabilityError = null;
    });

    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);

      // Check availability
      final isAvailable = await bookingRepo.isRoomAvailable(
        _selectedRoom!.id,
        _checkInDate!,
        _checkOutDate!,
      );

      if (!isAvailable) {
        setState(() {
          _availabilityError =
              '${_selectedRoom!.name} is already booked for these dates. Please choose different dates or another room.';
          _isLoading = false;
        });
        return;
      }

      final user = ref.read(authStateProvider).value;
      final now = DateTime.now();

      final booking = Booking(
        id: '',
        roomId: _selectedRoom!.id,
        roomName: _selectedRoom!.name,
        guestName: _guestNameController.text.trim(),
        guestPhone: _guestPhoneController.text.trim(),
        numberOfGuests: _numberOfGuests,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        idProof: _idProofController.text.trim().isNotEmpty
            ? _idProofController.text.trim()
            : null,
        specialRequests: _specialRequestsController.text.trim().isNotEmpty
            ? _specialRequestsController.text.trim()
            : null,
        addOns: _selectedAddOns,
        totalPrice: _calculateTotalPrice(),
        status: BookingStatus.confirmed,
        createdBy: user?.uid ?? '',
        propertyId: AppConstants.defaultPropertyId,
        createdAt: now,
        updatedAt: now,
      );

      await bookingRepo.addBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking created for ${booking.guestName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
    final roomsAsync = ref.watch(roomsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Room selection
            _buildSectionHeader('Room', Icons.bed_outlined),
            const SizedBox(height: 8),
            roomsAsync.when(
              data: (rooms) => _buildRoomSelector(rooms, colorScheme),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading rooms: $e'),
            ),
            const SizedBox(height: 24),

            // Guest details
            _buildSectionHeader('Guest Details', Icons.person_outlined),
            const SizedBox(height: 8),
            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(
                labelText: 'Guest Name *',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _guestPhoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone is required';
                if (v.trim().length < 10) return 'Enter valid phone number';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Number of guests
            _buildGuestCountSelector(colorScheme),
            const SizedBox(height: 24),

            // Dates
            _buildSectionHeader('Dates', Icons.calendar_today_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildDateTile('Check-in', _checkInDate, true, colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _buildDateTile('Check-out', _checkOutDate, false, colorScheme)),
              ],
            ),
            if (_checkInDate != null && _checkOutDate != null) ...[
              const SizedBox(height: 8),
              Text(
                '${AppDateUtils.calculateNights(_checkInDate!, _checkOutDate!)} night(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            // Availability error
            if (_availabilityError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _availabilityError!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Optional fields
            _buildOptionalFieldsSection(colorScheme),
            const SizedBox(height: 24),

            // Price summary
            if (_selectedRoom != null &&
                _checkInDate != null &&
                _checkOutDate != null)
              _buildPriceSummary(theme, colorScheme),
            const SizedBox(height: 16),

            // Create button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createBooking,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isLoading ? 'Creating...' : 'Create Booking'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildRoomSelector(List<Room> rooms, ColorScheme colorScheme) {
    return DropdownButtonFormField<Room>(
      initialValue: _selectedRoom,
      decoration: const InputDecoration(
        labelText: 'Select Room *',
        prefixIcon: Icon(Icons.bed_outlined),
      ),
      items: rooms.map((room) {
        final price = _numberOfGuests == 1
            ? room.pricePerNightSingle
            : room.pricePerNightDouble;
        return DropdownMenuItem(
          value: room,
          child: Text('${room.name} — ₹${price.toInt()}/night'),
        );
      }).toList(),
      onChanged: (room) {
        setState(() {
          _selectedRoom = room;
          _availabilityError = null;
        });
      },
      validator: (v) => v == null ? 'Please select a room' : null,
    );
  }

  Widget _buildGuestCountSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Guests *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 1,
              label: Text('Single (1)'),
              icon: Icon(Icons.person),
            ),
            ButtonSegment(
              value: 2,
              label: Text('Double (2)'),
              icon: Icon(Icons.people),
            ),
          ],
          selected: {_numberOfGuests},
          onSelectionChanged: (Set<int> selection) {
            setState(() {
              _numberOfGuests = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateTile(
      String label, DateTime? date, bool isCheckIn, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => _selectDate(isCheckIn: isCheckIn),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? AppDateUtils.formatDisplay(date)
                      : 'Select date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            date != null ? FontWeight.w600 : FontWeight.normal,
                        color: date != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalFieldsSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _showOptionalFields = !_showOptionalFields),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Icon(Icons.expand_more,
                  color: colorScheme.primary,
                  size: 20,
                  // ignore: deprecated_member_use
                  ),
              const SizedBox(width: 4),
              Text(
                'Optional Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: _showOptionalFields ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.expand_more, color: colorScheme.primary),
              ),
            ],
          ),
        ),
        if (_showOptionalFields) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _idProofController,
            decoration: const InputDecoration(
              labelText: 'ID Proof Number',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _specialRequestsController,
            decoration: const InputDecoration(
              labelText: 'Special Requests',
              prefixIcon: Icon(Icons.note_outlined),
              hintText: 'Any special requirements...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Text(
            'Add-ons',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _availableAddOns.map((addon) {
              final isSelected = _selectedAddOns.contains(addon);
              return FilterChip(
                label: Text(addon),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAddOns.add(addon);
                    } else {
                      _selectedAddOns.remove(addon);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSummary(ThemeData theme, ColorScheme colorScheme) {
    final nights = AppDateUtils.calculateNights(_checkInDate!, _checkOutDate!);
    final ratePerNight = _numberOfGuests == 1
        ? _selectedRoom!.pricePerNightSingle
        : _selectedRoom!.pricePerNightDouble;
    final total = _calculateTotalPrice();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Summary',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _priceRow('${_selectedRoom!.name} × $nights night(s)', ''),
          _priceRow(
            '₹${ratePerNight.toInt()} × $nights',
            '₹${total.toInt()}',
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₹${total.toInt()}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          if (value.isNotEmpty)
            Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
