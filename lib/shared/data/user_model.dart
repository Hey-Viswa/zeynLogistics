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

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.photoUrl,
    this.role,
    this.isVerified = false,
    required this.createdAt,
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
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? role,
    bool? isVerified,
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
    );
  }
}
