import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height;
  final double? weight;
  final String? fitnessLevel;
  final String? goal;
  final Map<String, dynamic>? onboarding;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.fitnessLevel,
    this.goal,
    this.onboarding,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      gender: data['gender'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      fitnessLevel: data['fitnessLevel'],
      goal: data['goal'],
      onboarding: data['onboarding'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'height': height,
      'weight': weight,
      'fitnessLevel': fitnessLevel,
      'goal': goal,
      'onboarding': onboarding,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? fitnessLevel,
    String? goal,
    Map<String, dynamic>? onboarding,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goal: goal ?? this.goal,
      onboarding: onboarding ?? this.onboarding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
