import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

enum TripStatus { waiting, accepted, onWay, completed }

class Trip {
  final String id;
  final String pickup;
  final String drop;
  final DateTime date;
  final String vehicle;
  final TripStatus status;
  final String? driverId;
  final double price;

  Trip({
    required this.id,
    required this.pickup,
    required this.drop,
    required this.date,
    required this.vehicle,
    this.status = TripStatus.waiting,
    this.driverId,
    this.price = 0.0,
  });

  Trip copyWith({TripStatus? status, String? driverId}) {
    return Trip(
      id: id,
      pickup: pickup,
      drop: drop,
      date: date,
      vehicle: vehicle,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      price: price,
    );
  }
}

class TripNotifier extends StateNotifier<List<Trip>> {
  TripNotifier() : super([]);

  final _uuid = const Uuid();

  void bookRide(String pickup, String drop, String vehicle, DateTime date) {
    final newTrip = Trip(
      id: _uuid.v4(),
      pickup: pickup,
      drop: drop,
      vehicle: vehicle,
      date: date,
      price: 150.0, // Mock price
    );
    state = [...state, newTrip];
  }

  void acceptRide(String tripId, String driverId) {
    state = [
      for (final trip in state)
        if (trip.id == tripId)
          trip.copyWith(status: TripStatus.accepted, driverId: driverId)
        else
          trip,
    ];
  }

  void startRide(String tripId) {
    state = [
      for (final trip in state)
        if (trip.id == tripId)
          trip.copyWith(status: TripStatus.onWay)
        else
          trip,
    ];
  }

  void completeRide(String tripId) {
    state = [
      for (final trip in state)
        if (trip.id == tripId)
          trip.copyWith(status: TripStatus.completed)
        else
          trip,
    ];
  }
}

final tripProvider = StateNotifierProvider<TripNotifier, List<Trip>>((ref) {
  return TripNotifier();
});
