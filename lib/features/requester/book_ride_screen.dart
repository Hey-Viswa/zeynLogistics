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
  String _selectedVehicle = 'Bike';

  final List<VehicleOption> _vehicleOptions = [
    const VehicleOption(
      name: 'Bike',
      icon: Icons.two_wheeler,
      price: 45,
      eta: '2 min',
      capacity: '1',
    ),
    const VehicleOption(
      name: 'Car',
      icon: Icons.directions_car,
      price: 150,
      eta: '4 min',
      capacity: '4',
    ),
    const VehicleOption(
      name: 'Van',
      icon: Icons.airport_shuttle,
      price: 450,
      eta: '12 min',
      capacity: '6',
    ),
    const VehicleOption(
      name: 'Truck',
      icon: Icons.local_shipping,
      price: 1200,
      eta: '25 min',
      capacity: 'Load',
    ),
  ];

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
            const SizedBox(height: 24),
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              icon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Choose your ride',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vehicleOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _vehicleOptions[index];
                final isSelected = _selectedVehicle == option.name;
                return _buildVehicleOption(context, option, isSelected);
              },
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
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71), // Access green color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Select $_selectedVehicle',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption(
    BuildContext context,
    VehicleOption option,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = option.name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F8F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Vehicle Icon (Mocking the 3D look with icons + background)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, size: 32, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        option.eta,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.circle, size: 4, color: Colors.grey),
                      const SizedBox(width: 8),
                      Icon(Icons.person, size: 12, color: Colors.grey.shade600),
                      Text(
                        ' ${option.capacity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Price
            Text(
              '₹${option.price}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}

class VehicleOption {
  final String name;
  final IconData icon;
  final int price;
  final String eta;
  final String capacity;

  const VehicleOption({
    required this.name,
    required this.icon,
    required this.price,
    required this.eta,
    required this.capacity,
  });
}
