import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/services/trip_repository.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import '../../shared/data/user_model.dart';
import '../../shared/widgets/scale_button.dart';

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
  final _uuid = const Uuid();

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
    final user = ref
        .watch(
          userStreamProvider(ref.watch(authStateProvider).value?.uid ?? ''),
        )
        .value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Book a Ride',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ScaleButton(
          onTap: () => context.pop(),
          child: const Icon(Icons.close), // Simplified close icon
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16.h),

                    // 1. Trip Card (Simplified M3 Container)
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme
                            .surfaceContainerLow, // M3 Container Color
                        borderRadius: BorderRadius.circular(20.r),
                        // No BoxShadow for simple M3 look
                      ),
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          _buildInputRow(
                            context,
                            controller: _pickupController,
                            hint: 'Pickup Location',
                            icon: Icons.my_location,
                            iconColor: colorScheme.primary,
                            isLast: false,
                          ),
                          _buildInputRow(
                            context,
                            controller: _dropController,
                            hint: 'Where to?',
                            icon: Icons.location_on,
                            iconColor: colorScheme.error,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h), // Keeping this one
                    // 2. Schedule
                    Row(
                      children: [
                        Text(
                          'Schedule',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        ScaleButton(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  DateFormat(
                                    'EEE, MMM d',
                                  ).format(_selectedDate),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // 3. Vehicle Selection
                    Text(
                      'Choose Vehicle',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 100.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: _vehicleOptions.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final option = _vehicleOptions[index];
                          return _buildVehicleCard(
                            context,
                            option,
                            _selectedVehicle == option.name,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 4. Notes
                    TextField(
                      controller: _notesController,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: 'Add note for driver...',
                        prefixIcon: Icon(Icons.edit_note, size: 22.sp),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // 5. Button (M3 FilledButton)
                    ScaleButton(
                      onTap: () => _handleBooking(context, user),
                      child: Container(
                        width: double.infinity,
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: colorScheme.primary, // Flat color, no gradient
                          borderRadius: BorderRadius.circular(
                            30.r,
                          ), // Pill shape
                        ),
                        child: Center(
                          child: Text(
                            'Confirm Request',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputRow(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              SizedBox(height: 12.h),
              Icon(icon, color: iconColor, size: 20.sp),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              if (!isLast) SizedBox(height: 4.h),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                if (!isLast)
                  SizedBox(height: 16.h), // Extend height for spacing
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    VehicleOption option,
    bool isSelected,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ScaleButton(
      onTap: () => setState(() => _selectedVehicle = option.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
          // No shadow, flat aesthetics
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              size: 28.sp,
              color: isSelected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurface,
            ),
            SizedBox(height: 8.h),
            Text(
              option.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              option.eta,
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBooking(BuildContext context, UserModel user) async {
    if (_pickupController.text.isEmpty || _dropController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter locations'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    final selectedOption = _vehicleOptions.firstWhere(
      (opt) => opt.name == _selectedVehicle,
    );

    final newTrip = Trip(
      id: _uuid.v4(),
      requesterId: user.id,
      requesterName: user.name ?? 'Guest',
      requesterPhone: user.phoneNumber,
      pickup: _pickupController.text,
      drop: _dropController.text,
      vehicle: _selectedVehicle,
      date: _selectedDate,
      price: selectedOption.price.toDouble(),
      status: TripStatus.waiting,
    );

    await ref.read(tripRepositoryProvider).createTrip(newTrip);

    if (context.mounted) {
      context.push('/trip-status', extra: newTrip);
    }
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
