import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/data/trip_provider.dart';
import '../../shared/widgets/map_placeholder.dart';

class TripStatusScreen extends ConsumerWidget {
  final String tripId;

  const TripStatusScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the specific trip.
    final trip = ref
        .watch(tripProvider)
        .firstWhere(
          (t) => t.id == tripId,
          orElse: () => Trip(
            id: 'error',
            pickup: 'Unknown',
            drop: 'Unknown',
            vehicle: 'Unknown',
            date: DateTime.now(),
            status: TripStatus.waiting,
          ),
        );

    if (trip.id == 'error') {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Not Found')),
        body: const Center(child: Text('Trip not found')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Trip Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: MapPlaceholder(
                label: 'Tracking route (coming soon)',
                icon: Icons.navigation_outlined,
                height: 220,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(context, trip),
                  const SizedBox(height: 24),
                  if (trip.driverId != null) ...[
                    _buildDriverInfo(context),
                    const Divider(height: 32),
                  ],
                  _buildLocationInfo(context, trip),
                  const SizedBox(height: 24),
                  if (trip.status == TripStatus.waiting)
                    OutlinedButton(
                      onPressed: () {
                        // Mock cancel logic would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cancel feature coming soon'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Cancel Request'),
                    ),
                ],
              ),
            ),
          ],
        ),
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
        color = Colors.orange;
        break;
      case TripStatus.accepted:
        statusTitle = 'Driver is on the way';
        statusSubtitle = 'Driver has accepted your request';
        icon = Icons.directions_car;
        color = Colors.blue;
        break;
      case TripStatus.onWay:
        statusTitle = 'Trip in Progress';
        statusSubtitle = 'You are on your way to the destination';
        icon = Icons.near_me;
        color = Colors.purple;
        break;
      case TripStatus.completed:
        statusTitle = 'Trip Completed';
        statusSubtitle = 'You have arrived at your destination';
        icon = Icons.check_circle;
        color = Colors.green;
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                statusSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'John Doe',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('4.8', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Text(
                  '• Toyota Van (XYZ-123)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.phone),
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
        const SizedBox(height: 16),
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
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
