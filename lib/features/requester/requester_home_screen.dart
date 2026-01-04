import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/data/trip_provider.dart';

class RequesterHomeScreen extends ConsumerWidget {
  const RequesterHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripProvider);
    final activeTrips = trips
        .where((t) => t.status != TripStatus.completed)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Hello,\nRequester',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          if (activeTrips.isEmpty)
            _buildEmptyState(context)
          else
            ...activeTrips.map((trip) => _buildTripCard(context, trip)),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/book-ride'),
            icon: const Icon(Icons.add),
            label: const Text('Book a Ride'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No active trips yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    ),
                  ),
                  _buildStatusChip(context, trip.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.my_location, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(trip.pickup)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(trip.drop)),
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
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
