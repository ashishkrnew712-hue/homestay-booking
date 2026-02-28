import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homestay_booking/features/rooms/domain/room_model.dart';
import 'package:homestay_booking/shared/providers/firestore_providers.dart';

/// Screen for editing room details and pricing.
class RoomSettingsScreen extends ConsumerStatefulWidget {
  const RoomSettingsScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends ConsumerState<RoomSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _singlePriceController = TextEditingController();
  final _doublePriceController = TextEditingController();
  final _weekendSingleController = TextEditingController();
  final _weekendDoubleController = TextEditingController();

  final List<String> _amenities = [];
  final _amenityController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _singlePriceController.dispose();
    _doublePriceController.dispose();
    _weekendSingleController.dispose();
    _weekendDoubleController.dispose();
    _amenityController.dispose();
    super.dispose();
  }

  void _initFromRoom(Room room) {
    if (_initialized) return;
    _nameController.text = room.name;
    _descriptionController.text = room.description;
    _singlePriceController.text = room.pricePerNightSingle.toInt().toString();
    _doublePriceController.text = room.pricePerNightDouble.toInt().toString();
    _weekendSingleController.text = room.weekendPricePerNightSingle.toInt().toString();
    _weekendDoubleController.text = room.weekendPricePerNightDouble.toInt().toString();
    _amenities.addAll(room.amenities);
    _initialized = true;
  }

  Future<void> _saveRoom(Room original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updated = original.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        pricePerNightSingle: double.parse(_singlePriceController.text.trim()),
        pricePerNightDouble: double.parse(_doublePriceController.text.trim()),
        weekendPricePerNightSingle: double.parse(_weekendSingleController.text.trim()),
        weekendPricePerNightDouble: double.parse(_weekendDoubleController.text.trim()),
        amenities: List<String>.from(_amenities),
        updatedAt: DateTime.now(),
      );

      await ref.read(roomRepositoryProvider).updateRoom(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Room updated'),
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
    final roomsAsync = ref.watch(roomsStreamProvider);

    return roomsAsync.when(
      data: (rooms) {
        final room = rooms.where((r) => r.id == widget.roomId).firstOrNull;
        if (room == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Room Settings')),
            body: const Center(child: Text('Room not found')),
          );
        }
        _initFromRoom(room);
        return _buildForm(room, theme, colorScheme);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Room Settings')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Room Settings')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Scaffold _buildForm(Room room, ThemeData theme, ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${room.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic info
            _sectionHeader('Room Details', Icons.info_outlined, colorScheme),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Room Name *',
                prefixIcon: Icon(Icons.bed_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Weekday pricing
            _sectionHeader('Weekday Pricing (Mon–Thu)', Icons.payments_outlined, colorScheme),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _priceField(_singlePriceController, 'Single /night')),
                const SizedBox(width: 12),
                Expanded(child: _priceField(_doublePriceController, 'Double /night')),
              ],
            ),
            const SizedBox(height: 24),

            // Weekend pricing
            _sectionHeader('Weekend Pricing (Fri–Sat)', Icons.weekend_outlined, colorScheme),
            const SizedBox(height: 4),
            Text(
              'Automatically applied for Friday and Saturday nights',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _priceField(_weekendSingleController, 'Single /night')),
                const SizedBox(width: 12),
                Expanded(child: _priceField(_weekendDoubleController, 'Double /night')),
              ],
            ),
            const SizedBox(height: 24),

            // Amenities
            _sectionHeader('Amenities', Icons.room_service_outlined, colorScheme),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amenityController,
                    decoration: const InputDecoration(
                      hintText: 'Add amenity...',
                      prefixIcon: Icon(Icons.add),
                      isDense: true,
                    ),
                    onSubmitted: _addAmenity,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _addAmenity(_amenityController.text),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _amenities.map((a) => Chip(
                label: Text(a),
                onDeleted: () => setState(() => _amenities.remove(a)),
              )).toList(),
            ),
            const SizedBox(height: 32),

            // Save
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _saveRoom(room),
                icon: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
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

  Widget _sectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _priceField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '₹ ',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final n = int.tryParse(v.trim());
        if (n == null || n <= 0) return 'Must be > 0';
        return null;
      },
    );
  }

  void _addAmenity(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_amenities.contains(trimmed)) {
      setState(() {
        _amenities.add(trimmed);
        _amenityController.clear();
      });
    }
  }
}
