import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/services/trip_repository.dart';
import '../../shared/widgets/map_placeholder.dart';

final tripStreamProvider = StreamProvider.family<Trip?, String>((ref, tripId) {
  return ref.watch(tripRepositoryProvider).streamTrip(tripId);
});

class TripStatusScreen extends ConsumerWidget {
  final String tripId;

  const TripStatusScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripStreamProvider(tripId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Trip Status'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          // If canceled or completed, go home. If waiting, maybe confirm cancel?
          onPressed: () => context.go('/home'),
        ),
      ),
      body: tripAsync.when(
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found or canceled.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: MapPlaceholder(
                    label: 'Tracking route (coming soon)',
                    icon: Icons.navigation_outlined,
                    height: 220.h,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Hero(
                          tag: 'trip_title_${trip.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              'Trip #${trip.id.substring(0, 4)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 18.sp,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildStatusHeader(context, trip),
                      SizedBox(height: 24.h),
                      if (trip.driverId != null) ...[
                        _buildDriverInfo(context, trip),
                        Divider(height: 32.h),
                      ],
                      _buildLocationInfo(context, trip),
                      SizedBox(height: 24.h),
                      if (trip.status == TripStatus.waiting)
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cancel feature coming soon'),
                              ),
                            );
                            // Future: Call tripRepository.updateTripStatus(canceled)
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            minimumSize: Size.fromHeight(48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Cancel Request',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Trip trip) {
    String statusTitle;
    String statusSubtitle;
    IconData icon;
    Color color;

    switch (trip.status) {
      case TripStatus.waiting:
        statusTitle = 'Looking for a driver';
        statusSubtitle = 'We are matching you with nearby drivers';
        icon = Icons.search;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case TripStatus.accepted:
        statusTitle = 'Driver is on the way';
        statusSubtitle = 'Driver has accepted your request';
        icon = Icons.directions_car;
        color = Theme.of(context).colorScheme.primary;
        break;
      case TripStatus.onWay:
        statusTitle = 'Trip in Progress';
        statusSubtitle = 'You are on your way to the destination';
        icon = Icons.near_me;
        color = Theme.of(context).colorScheme.tertiary; // Or primary
        break;
      case TripStatus.completed:
        statusTitle = 'Trip Completed';
        statusSubtitle = 'You have arrived at your destination';
        icon = Icons.check_circle;
        color = Theme.of(context).colorScheme.primary;
        break;
      case TripStatus.canceled:
        statusTitle = 'Trip Canceled';
        statusSubtitle = 'This trip was canceled';
        icon = Icons.cancel;
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              Text(
                statusSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo(BuildContext context, Trip trip) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          child: Icon(Icons.person, size: 28.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.driverName ?? 'Driver',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  trip.driverPhone ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.phone, size: 24.sp),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(BuildContext context, Trip trip) {
    return Column(
      children: [
        _buildLocationRow(context, Icons.my_location, 'Pickup', trip.pickup),
        SizedBox(height: 16.h),
        _buildLocationRow(context, Icons.location_on, 'Drop-off', trip.drop),
      ],
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
