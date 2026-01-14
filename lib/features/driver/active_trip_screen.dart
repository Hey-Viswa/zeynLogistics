import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/widgets/map_placeholder.dart';

class ActiveTripScreen extends ConsumerWidget {
  final Trip trip;

  const ActiveTripScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrip = ref
        .watch(tripProvider)
        .firstWhere((t) => t.id == trip.id, orElse: () => trip);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Current Trip'),
        leading: IconButton(
          icon: Icon(Icons.close, size: 24.sp),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MapPlaceholder(
              label: 'Navigation will appear here',
              icon: Icons.navigation,
              height: 200.h,
            ),
            SizedBox(height: 24.h),
            _buildStatusCard(context, currentTrip),
            SizedBox(height: 32.h),
            _buildLocationSteppers(context, currentTrip),
            const Spacer(),
            if (currentTrip.status == TripStatus.accepted)
              FilledButton.icon(
                onPressed: () {
                  ref.read(tripProvider.notifier).startRide(trip.id);
                },
                icon: Icon(Icons.play_arrow, size: 20.sp),
                label: Text('Start Trip', style: TextStyle(fontSize: 16.sp)),
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(56.h),
                ),
              )
            else if (currentTrip.status == TripStatus.onWay)
              FilledButton.icon(
                onPressed: () {
                  ref.read(tripProvider.notifier).completeRide(trip.id);
                  context.pop(); // Go back to home
                },
                icon: Icon(Icons.check, size: 20.sp),
                label: Text('Complete Trip', style: TextStyle(fontSize: 16.sp)),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: Size.fromHeight(56.h),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Trip trip) {
    String statusText;
    Color statusColor;

    switch (trip.status) {
      case TripStatus.accepted:
        statusText = 'Head to Pickup';
        statusColor = Theme.of(context).colorScheme.tertiary;
        break;
      case TripStatus.onWay:
        statusText = 'On the Way';
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Theme.of(context).colorScheme.outline;
    }

    return Card(
      color: statusColor,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Text(
              statusText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Est. arrival in 15 mins',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSteppers(BuildContext context, Trip trip) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  Icons.my_location,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
                Container(
                  height: 40.h,
                  width: 2.w,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    trip.pickup,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.error,
              size: 20.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drop-off',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    trip.drop,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
