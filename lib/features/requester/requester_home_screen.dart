import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/services/trip_repository.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';

final userTripsProvider = StreamProvider<List<Trip>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(tripRepositoryProvider).streamUserTrips(user.uid);
});

class RequesterHomeScreen extends ConsumerWidget {
  const RequesterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(
      userStreamProvider(ref.watch(authStateProvider).value?.uid ?? ''),
    );
    final tripsAsync = ref.watch(userTripsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Hello,\n${userAsync.value?.name?.split(' ').first ?? 'Requester'}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 28.sp),
                ),
              ),
              IconButton(
                onPressed: () => context.push('/profile'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: userAsync.value?.photoUrl != null
                      ? NetworkImage(userAsync.value!.photoUrl!)
                      : null,
                  child: userAsync.value?.photoUrl == null
                      ? Icon(Icons.person, size: 24.sp)
                      : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          tripsAsync.when(
            data: (trips) {
              final activeTrips = trips
                  .where(
                    (t) =>
                        t.status != TripStatus.completed &&
                        t.status != TripStatus.canceled,
                  )
                  .toList();

              if (activeTrips.isEmpty) {
                return _buildEmptyState(context);
              }
              return Column(
                children: activeTrips
                    .map((trip) => _buildTripCard(context, trip))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),

          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: () => context.push('/book-ride'),
            icon: Icon(Icons.add, size: 20.sp),
            label: Text('Book a Ride', style: TextStyle(fontSize: 16.sp)),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'No active trips yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    return GestureDetector(
      onTap: () => context.push('/trip-status/${trip.id}'),
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trip #${trip.id.substring(0, 4)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  _buildStatusChip(context, trip.status),
                ],
              ),
              Divider(height: 24.h),
              Row(
                children: [
                  Icon(Icons.my_location, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(trip.pickup, style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(trip.drop, style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, TripStatus status) {
    Color color;
    String label;

    switch (status) {
      case TripStatus.waiting:
        color = Colors.orange;
        label = 'Waiting';
        break;
      case TripStatus.accepted:
        color = Colors.blue;
        label = 'Accepted';
        break;
      case TripStatus.onWay:
        color = Colors.purple;
        label = 'On Way';
        break;
      case TripStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case TripStatus.canceled:
        color = Colors.red;
        label = 'Canceled';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
