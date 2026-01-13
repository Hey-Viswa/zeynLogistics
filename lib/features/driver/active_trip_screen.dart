import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MapPlaceholder(
              label: 'Navigation will appear here',
              icon: Icons.navigation,
            ),
            const SizedBox(height: 24),
            _buildStatusCard(context, currentTrip),
            const SizedBox(height: 32),
            _buildLocationSteppers(context, currentTrip),
            const Spacer(),
            if (currentTrip.status == TripStatus.accepted)
              FilledButton.icon(
                onPressed: () {
                  ref.read(tripProvider.notifier).startRide(trip.id);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Trip'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              )
            else if (currentTrip.status == TripStatus.onWay)
              FilledButton.icon(
                onPressed: () {
                  ref.read(tripProvider.notifier).completeRide(trip.id);
                  context.pop(); // Go back to home
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete Trip'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(56),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              statusText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Est. arrival in 15 mins',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
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
                ),
                Container(
                  height: 40,
                  width: 2,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.pickup,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drop-off',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.drop,
                    style: Theme.of(context).textTheme.titleLarge,
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
