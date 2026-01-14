import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/trip_provider.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripProvider);

    // In a real app, we would filter by location or other criteria.
    // For MVP, we show 'waiting' trips as available.
    final availableTrips = trips
        .where((t) => t.status == TripStatus.waiting)
        .toList();

    // Also check if driver has an active trip
    final activeTrip = trips
        .where(
          (t) =>
              (t.status == TripStatus.accepted ||
                  t.status == TripStatus.onWay) &&
              t.driverId == 'current_driver', // Mock ID
        )
        .firstOrNull;

    if (activeTrip != null) {
      // Redirect or show active trip card?
      // For simplicity, we just show a prominent card to go to active trip.
    }

    return _isOnline
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: 24.h),
                if (activeTrip != null) ...[
                  _buildActiveTripAlert(context, activeTrip),
                  SizedBox(height: 24.h),
                ],
                Text(
                  'Available Requests',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 16.h),
                if (availableTrips.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Center(
                      child: Text(
                        'No new requests nearby.',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  )
                else
                  ...availableTrips.map(
                    (trip) => _buildTripCard(context, ref, trip),
                  ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Expanded(child: _buildOfflineState(context)),
            ],
          );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
              ),
              Text(
                'Driver',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 28.sp),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildOnlineToggle(context),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => context.push('/profile'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: CircleAvatar(
                radius: 18.r,
                child: Icon(Icons.person, size: 20.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOnlineToggle(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _isOnline = !_isOnline;
        });
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _isOnline
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: _isOnline
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.power_settings_new,
              size: 20.sp,
              color: _isOnline
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            SizedBox(width: 8.w),
            Text(
              _isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: _isOnline
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64.sp,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 16.h),
            Text(
              'You are offline',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Go online to receive trip requests',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripAlert(BuildContext context, Trip trip) {
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      margin: EdgeInsets.only(bottom: 24.h),
      child: ListTile(
        leading: Icon(Icons.navigation, size: 24.sp),
        title: Text(
          'Trip in Progress',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('To: ${trip.drop}', style: TextStyle(fontSize: 14.sp)),
        trailing: Icon(Icons.chevron_right, size: 24.sp),
        onTap: () => context.push('/active-trip', extra: trip),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, WidgetRef ref, Trip trip) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(trip.vehicle, style: TextStyle(fontSize: 12.sp)),
                  avatar: Icon(Icons.directions_car, size: 16.sp),
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildLocationRow(Icons.my_location, trip.pickup),
            SizedBox(height: 8.h),
            _buildLocationRow(Icons.location_on, trip.drop),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(tripProvider.notifier)
                      .acceptRide(trip.id, 'current_driver');
                  // Navigate to active trip
                  context.push('/active-trip', extra: trip);
                },
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('Accept Trip', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}
