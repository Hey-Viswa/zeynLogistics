import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String? photoUrl; // Added for Google Auth
  final String? role; // 'driver' or 'requester'
  final String? verificationStatus; // 'pending', 'verified', 'rejected'
  final bool isVerified;
  final DateTime createdAt;
  final List<String> savedPlaces;
  final Map<String, dynamic> paymentMethods;
  final Map<String, String> documents; // New field for driver docs
  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.photoUrl,
    this.role,
    this.isVerified = false,
    this.verificationStatus,
    required this.createdAt,
    this.savedPlaces = const [],
    this.paymentMethods = const {},
    this.documents = const {},
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
      'verificationStatus': verificationStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'savedPlaces': savedPlaces,
      'paymentMethods': paymentMethods,
      'documents': documents,
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
      verificationStatus: map['verificationStatus'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      savedPlaces: List<String>.from(map['savedPlaces'] ?? []),
      paymentMethods: Map<String, dynamic>.from(map['paymentMethods'] ?? {}),
      documents: Map<String, String>.from(map['documents'] ?? {}),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? role,
    bool? isVerified,
    String? verificationStatus,
    List<String>? savedPlaces,
    Map<String, dynamic>? paymentMethods,
    Map<String, String>? documents,
  }) {
    return UserModel(
      id: id,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      documents: documents ?? this.documents,
    );
  }
}
