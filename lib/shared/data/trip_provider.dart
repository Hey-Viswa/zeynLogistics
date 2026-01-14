import 'package:cloud_firestore/cloud_firestore.dart';

enum TripStatus { waiting, accepted, onWay, completed, canceled }

class Trip {
  final String id;
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final String pickup;
  final String drop;
  final DateTime date;
  final String vehicle;
  final TripStatus status;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final double price;
  final String distance;
  final String duration;

  Trip({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.pickup,
    required this.drop,
    required this.date,
    required this.vehicle,
    this.status = TripStatus.waiting,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.price = 0.0,
    this.distance = '',
    this.duration = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'pickup': pickup,
      'drop': drop,
      'date': Timestamp.fromDate(date),
      'vehicle': vehicle,
      'status': status.toString(),
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'price': price,
      'distance': distance,
      'duration': duration,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map, String docId) {
    return Trip(
      id: docId,
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? 'Unknown',
      requesterPhone: map['requesterPhone'] ?? '',
      pickup: map['pickup'] ?? '',
      drop: map['drop'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vehicle: map['vehicle'] ?? 'Bike',
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => TripStatus.waiting,
      ),
      driverId: map['driverId'],
      driverName: map['driverName'],
      driverPhone: map['driverPhone'],
      price: (map['price'] ?? 0.0).toDouble(),
      distance: map['distance'] ?? '',
      duration: map['duration'] ?? '',
    );
  }

  Trip copyWith({
    TripStatus? status,
    String? driverId,
    String? driverName,
    String? driverPhone,
  }) {
    return Trip(
      id: id,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterPhone: requesterPhone,
      pickup: pickup,
      drop: drop,
      date: date,
      vehicle: vehicle,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      price: price,
      distance: distance,
      duration: duration,
    );
  }
}
