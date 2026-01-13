import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
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
                const SizedBox(height: 24),
                if (activeTrip != null) ...[
                  _buildActiveTripAlert(context, activeTrip),
                  const SizedBox(height: 24),
                ],
                Text(
                  'Available Requests',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (availableTrips.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: Text('No new requests nearby.')),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning,', style: Theme.of(context).textTheme.bodyLarge),
            Text('Driver', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        Row(
          children: [
            _buildOnlineToggle(context),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 20),
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
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isOnline
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
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
              size: 20,
              color: _isOnline
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text(
              _isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'You are offline',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Go online to receive trip requests',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      margin: const EdgeInsets.only(bottom: 24),
      child: ListTile(
        leading: const Icon(Icons.navigation),
        title: const Text('Trip in Progress'),
        subtitle: Text('To: ${trip.drop}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/active-trip', extra: trip),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, WidgetRef ref, Trip trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(trip.vehicle),
                  avatar: const Icon(Icons.directions_car, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationRow(Icons.my_location, trip.pickup),
            const SizedBox(height: 8),
            _buildLocationRow(Icons.location_on, trip.drop),
            const SizedBox(height: 24),
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
                child: const Text('Accept Trip'),
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
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
