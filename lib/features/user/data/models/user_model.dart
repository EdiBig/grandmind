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
  final Map<String, dynamic>? preferences;
  final bool hasCompletedOnboarding;
  final String? signInProvider;
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
    this.preferences,
    this.hasCompletedOnboarding = false,
    this.signInProvider,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'] ?? data['photoURL'],
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
      preferences: data['preferences'] as Map<String, dynamic>?,
      hasCompletedOnboarding:
          data['hasCompletedOnboarding'] as bool? ??
          (data['onboarding']?['completed'] as bool? ?? false),
      signInProvider: data['signInProvider'] as String?,
      createdAt: _parseTimestampOrNow(data['createdAt']),
      updatedAt: _parseTimestampOrNow(data['updatedAt']),
    );
  }

  static DateTime _parseTimestampOrNow(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
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
      'preferences': preferences,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'signInProvider': signInProvider,
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
    Map<String, dynamic>? preferences,
    bool? hasCompletedOnboarding,
    String? signInProvider,
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
      preferences: preferences ?? this.preferences,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      signInProvider: signInProvider ?? this.signInProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
