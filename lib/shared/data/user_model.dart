import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? photoUrl; // Added for Google Auth
  final String? role; // 'driver' or 'requester'
  final bool isVerified;
  final DateTime createdAt;
  final List<String> savedPlaces;
  final Map<String, dynamic> paymentMethods;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.photoUrl,
    this.role,
    this.isVerified = false,
    required this.createdAt,
    this.savedPlaces = const [],
    this.paymentMethods = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'savedPlaces': savedPlaces,
      'paymentMethods': paymentMethods,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'],
      email: map['email'],
      photoUrl: map['photoUrl'],
      role: map['role'],
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      savedPlaces: List<String>.from(map['savedPlaces'] ?? []),
      paymentMethods: Map<String, dynamic>.from(map['paymentMethods'] ?? {}),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? role,
    bool? isVerified,
    List<String>? savedPlaces,
    Map<String, dynamic>? paymentMethods,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
