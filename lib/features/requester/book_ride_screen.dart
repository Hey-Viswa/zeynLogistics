import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/widgets/map_placeholder.dart';

class BookRideScreen extends ConsumerStatefulWidget {
  const BookRideScreen({super.key});

  @override
  ConsumerState<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends ConsumerState<BookRideScreen> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedVehicle = 'Car';

  final List<String> _vehicles = ['Bike', 'Car', 'Van', 'Truck'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Book a Ride')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MapPlaceholder(
              label: 'Map view will appear here',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _pickupController,
              label: 'Pickup Location',
              icon: Icons.my_location,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dropController,
              label: 'Drop Location',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 24),
            Text('Date & Time', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 16),
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vehicle Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _vehicles.map((v) {
                final isSelected = _selectedVehicle == v;
                return FilterChip(
                  label: Text(v),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedVehicle = v);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              icon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                if (_pickupController.text.isEmpty ||
                    _dropController.text.isEmpty) {
                  return;
                }

                ref
                    .read(tripProvider.notifier)
                    .bookRide(
                      _pickupController.text,
                      _dropController.text,
                      _selectedVehicle,
                      _selectedDate,
                    );

                context.pop();
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
