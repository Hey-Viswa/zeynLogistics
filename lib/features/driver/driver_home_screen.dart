import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/services/trip_repository.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_repository.dart';
import '../onboarding/role_provider.dart';
import '../../shared/widgets/scale_button.dart';

final waitingTripsProvider = StreamProvider<List<Trip>>((ref) {
  return ref.watch(tripRepositoryProvider).streamWaitingTrips();
});

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Get current driver user data
    final userAsync = ref.watch(
      userStreamProvider(ref.watch(authStateProvider).value?.uid ?? ''),
    );

    // 2. Stream waiting trips
    final waitingTripsAsync = ref.watch(waitingTripsProvider);

    // 3. Watch Driver Status
    final isOnline = ref.watch(driverStatusProvider);

    return isOnline
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                SizedBox(height: 24.h),
                Text(
                  'Available Requests',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 16.h),
                waitingTripsAsync.when(
                  data: (trips) {
                    if (trips.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: Center(
                          child: Text(
                            'No new requests nearby.',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: trips
                          .map(
                            (trip) => _buildTripCard(
                              context,
                              ref,
                              trip,
                              userAsync.value,
                            ),
                          )
                          .toList()
                          .animate(interval: 100.ms)
                          .fade(duration: 400.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
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
            IconButton(
              onPressed: () {
                // Open Chat
                final uid = ref.read(authServiceProvider).currentUser?.uid;
                if (uid != null) context.push('/chat/$uid');
              },
              icon: Icon(
                Icons.support_agent,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 8.w),
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
    final isOnline = ref.watch(driverStatusProvider);
    return ScaleButton(
      onTap: () async {
        // Haptic handled by ScaleButton
        await ref.read(driverStatusProvider.notifier).toggle();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isOnline
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isOnline
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.power_settings_new,
              size: 20.sp,
              color: isOnline
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            SizedBox(width: 8.w),
            Text(
              isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: isOnline
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

  Widget _buildTripCard(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
    var driverUser,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            _buildLocationRow(
              Icons.my_location,
              trip.pickup,
              heroTag: 'pickup_${trip.id}',
            ),
            SizedBox(height: 8.h),
            _buildLocationRow(Icons.location_on, trip.drop),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.person, size: 16.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  'Rider: ${trip.requesterName}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ScaleButton(
                onTap: () async {
                  if (driverUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error: Driver info not loaded'),
                      ),
                    );
                    return;
                  }
                  await ref
                      .read(tripRepositoryProvider)
                      .assignDriver(trip.id, driverUser);

                  if (context.mounted) {
                    context.push('/active-trip', extra: trip);
                  }
                },
                child: Container(
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(100.r), // Pill shape
                  ),
                  child: Text(
                    'Accept Trip',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String text, {String? heroTag}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: heroTag != null
              ? Hero(
                  tag: heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                )
              : Text(
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
