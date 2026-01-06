import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/user_stats_service.dart';
import '../../data/services/profile_photo_service.dart';

/// Provider for UserStatsService
final userStatsServiceProvider = Provider<UserStatsService>((ref) {
  return UserStatsService();
});

/// Provider for ProfilePhotoService
final profilePhotoServiceProvider = Provider<ProfilePhotoService>((ref) {
  return ProfilePhotoService();
});

/// Provider for user statistics
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return UserStats.empty();
  }

  final statsService = ref.watch(userStatsServiceProvider);
  return await statsService.getUserStats(userId);
});

/// Provider for specific stat - total workouts
final totalWorkoutsProvider = FutureProvider<int>((ref) async {
  final stats = await ref.watch(userStatsProvider.future);
  return stats.totalWorkouts;
});

/// Provider for specific stat - current streak
final currentStreakProvider = FutureProvider<int>((ref) async {
  final stats = await ref.watch(userStatsProvider.future);
  return stats.currentStreak;
});

/// Provider for specific stat - achievements
final achievementsCountProvider = FutureProvider<int>((ref) async {
  final stats = await ref.watch(userStatsProvider.future);
  return stats.achievementsUnlocked;
});
