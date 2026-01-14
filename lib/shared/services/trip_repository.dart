import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trip_provider.dart';
import '../data/user_model.dart'; // Import for driver/requester types if needed later

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(FirebaseFirestore.instance);
});

class TripRepository {
  final FirebaseFirestore _firestore;

  TripRepository(this._firestore);

  // 1. Create a Trip (Requester)
  Future<void> createTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).set(trip.toMap());
  }

  // 2. Stream all waiting trips (For Driver Home)
  Stream<List<Trip>> streamWaitingTrips() {
    return _firestore
        .collection('trips')
        .where('status', isEqualTo: TripStatus.waiting.toString())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Trip.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // 3. Stream a specific trip (For Tracking Screen)
  Stream<Trip?> streamTrip(String tripId) {
    return _firestore.collection('trips').doc(tripId).snapshots().map((doc) {
      if (doc.exists) {
        return Trip.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // 4. Update Trip Status (Driver)
  Future<void> updateTripStatus(String tripId, TripStatus status) async {
    await _firestore.collection('trips').doc(tripId).update({
      'status': status.toString(),
    });
  }

  // 5. Assign Driver (Accept Ride)
  Future<void> assignDriver(String tripId, UserModel driver) async {
    await _firestore.collection('trips').doc(tripId).update({
      'driverId': driver.id,
      'driverName': driver.name,
      'driverPhone': driver.phoneNumber,
      'status': TripStatus.accepted.toString(),
    });
  }

  // 6. Stream User Trips (Requester History)
  Stream<List<Trip>> streamUserTrips(String userId) {
    return _firestore
        .collection('trips')
        .where('requesterId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Trip.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
