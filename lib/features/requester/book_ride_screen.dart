import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/trip_provider.dart';

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
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Route',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 24.h),
            // Connected Inputs
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                children: [
                  // Pickup Input
                  Row(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24.sp,
                          ),
                          Container(
                            height: 40.h,
                            width: 2.w,
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ],
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildRouteField(
                          controller: _pickupController,
                          hint: 'Pickup Location',
                          isPickup: true,
                        ),
                      ),
                    ],
                  ),
                  // Drop Input
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 24.sp,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildRouteField(
                          controller: _dropController,
                          hint: 'Where to?',
                          isPickup: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Date & Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
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
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20.sp),
                    SizedBox(width: 16.w),
                    Text(
                      '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            _buildTextField(
              controller: _notesController,
              label: 'Notes (Optional)',
              icon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
            SizedBox(height: 24.h),
            Text(
              'Choose your ride',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 18.sp),
            ),
            SizedBox(height: 16.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vehicleOptions.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final option = _vehicleOptions[index];
                final isSelected = _selectedVehicle == option.name;
                return _buildVehicleOption(context, option, isSelected);
              },
            ),
            SizedBox(height: 32.h),
            FilledButton(
              onPressed: () {
                if (_pickupController.text.isEmpty ||
                    _dropController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please enter both Pickup and Drop locations',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  return;
                }

                HapticFeedback.mediumImpact();

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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.all(18.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Confirm Request',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedVehicle = option.name);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Vehicle Icon (Mocking the 3D look with icons + background)
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                option.icon,
                size: 32.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 16.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        option.eta,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.circle,
                        size: 4.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.person,
                        size: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      Text(
                        ' ${option.capacity}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
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
        prefixIcon: Icon(icon, size: 20.sp),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }

  Widget _buildRouteField({
    required TextEditingController controller,
    required String hint,
    required bool isPickup,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: isPickup
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          filled: false,
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
