import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/milestone.dart';

/// Service for checking and awarding milestones
class MilestoneService {
  final FirebaseFirestore _firestore;

  MilestoneService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all earned milestones for a user
  Future<List<Milestone>> getMilestones(String userId) async {
    final snapshot = await _firestore
        .collection('milestones')
        .where('userId', isEqualTo: userId)
        .orderBy('achievedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Milestone.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// Get milestone summary
  Future<MilestoneSummary> getMilestoneSummary(String userId) async {
    final allMilestones = await getMilestones(userId);

    if (allMilestones.isEmpty) {
      return MilestoneSummary.empty();
    }

    // Recent milestones (last 5)
    final recentMilestones = allMilestones.take(5).toList();

    // Count new (within last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final newCount = allMilestones
        .where((m) => m.achievedAt.isAfter(sevenDaysAgo))
        .length;

    // Count by type
    final countByType = <MilestoneType, int>{};
    for (final milestone in allMilestones) {
      countByType[milestone.type] = (countByType[milestone.type] ?? 0) + 1;
    }

    return MilestoneSummary(
      recentMilestones: recentMilestones,
      allMilestones: allMilestones,
      totalCount: allMilestones.length,
      newCount: newCount,
      countByType: countByType,
    );
  }

  /// Check and award new milestones based on current stats
  Future<List<Milestone>> checkAndAwardMilestones({
    required String userId,
    int? currentStreak,
    int? totalWorkouts,
    int? totalHabits,
    double? totalWeightLost,
  }) async {
    final newMilestones = <Milestone>[];
    final now = DateTime.now();

    // Get already earned milestones
    final earnedSnapshot = await _firestore
        .collection('milestones')
        .where('userId', isEqualTo: userId)
        .get();

    final earnedBadges = earnedSnapshot.docs
        .map((doc) => doc.data()['badge'] as String?)
        .whereType<String>()
        .toSet();

    // Check streak milestones
    if (currentStreak != null) {
      for (final def in MilestoneDefinitions.streakMilestones) {
        if (currentStreak >= def.threshold && !earnedBadges.contains(def.badge)) {
          final milestone = await _awardMilestone(
            userId: userId,
            type: MilestoneType.streak,
            def: def,
            achievedAt: now,
          );
          if (milestone != null) {
            newMilestones.add(milestone);
          }
        }
      }
    }

    // Check workout milestones
    if (totalWorkouts != null) {
      for (final def in MilestoneDefinitions.workoutMilestones) {
        if (totalWorkouts >= def.threshold && !earnedBadges.contains(def.badge)) {
          final milestone = await _awardMilestone(
            userId: userId,
            type: MilestoneType.workout,
            def: def,
            achievedAt: now,
          );
          if (milestone != null) {
            newMilestones.add(milestone);
          }
        }
      }
    }

    // Check habit milestones
    if (totalHabits != null) {
      for (final def in MilestoneDefinitions.habitMilestones) {
        if (totalHabits >= def.threshold && !earnedBadges.contains(def.badge)) {
          final milestone = await _awardMilestone(
            userId: userId,
            type: MilestoneType.habit,
            def: def,
            achievedAt: now,
          );
          if (milestone != null) {
            newMilestones.add(milestone);
          }
        }
      }
    }

    // Check weight milestones
    if (totalWeightLost != null && totalWeightLost > 0) {
      for (final def in MilestoneDefinitions.weightMilestones) {
        if (def.badge.contains('lost') &&
            totalWeightLost >= def.threshold &&
            !earnedBadges.contains(def.badge)) {
          final milestone = await _awardMilestone(
            userId: userId,
            type: MilestoneType.weight,
            def: def,
            achievedAt: now,
          );
          if (milestone != null) {
            newMilestones.add(milestone);
          }
        }
      }
    }

    return newMilestones;
  }

  /// Award a specific milestone
  Future<Milestone?> _awardMilestone({
    required String userId,
    required MilestoneType type,
    required MilestoneDef def,
    required DateTime achievedAt,
  }) async {
    try {
      final milestone = Milestone(
        id: '',
        userId: userId,
        type: type,
        title: def.title,
        description: def.description,
        badge: def.badge,
        achievedAt: achievedAt,
        isNew: true,
      );

      final docRef = await _firestore
          .collection('milestones')
          .add(milestone.toJson()..remove('id'));

      return milestone.copyWith(id: docRef.id);
    } catch (e) {
      return null;
    }
  }

  /// Check for first-time achievements
  Future<Milestone?> checkFirstTimeAchievement({
    required String userId,
    required String achievementType, // e.g., 'first_weigh_in', 'first_workout'
    required String title,
    required String description,
  }) async {
    // Check if already earned
    final existingSnapshot = await _firestore
        .collection('milestones')
        .where('userId', isEqualTo: userId)
        .where('badge', isEqualTo: achievementType)
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      return null; // Already earned
    }

    // Award the milestone
    final milestone = Milestone(
      id: '',
      userId: userId,
      type: MilestoneType.firstTime,
      title: title,
      description: description,
      badge: achievementType,
      achievedAt: DateTime.now(),
      isNew: true,
    );

    try {
      final docRef = await _firestore
          .collection('milestones')
          .add(milestone.toJson()..remove('id'));

      return milestone.copyWith(id: docRef.id);
    } catch (e) {
      return null;
    }
  }

  /// Mark milestones as seen (no longer new)
  Future<void> markMilestonesSeen(String userId) async {
    final snapshot = await _firestore
        .collection('milestones')
        .where('userId', isEqualTo: userId)
        .where('isNew', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isNew': false});
    }

    await batch.commit();
  }

  /// Get upcoming milestones (next to achieve)
  Future<List<MilestoneDef>> getUpcomingMilestones({
    required String userId,
    int? currentStreak,
    int? totalWorkouts,
    int? totalHabits,
    double? totalWeightLost,
  }) async {
    // Get already earned milestones
    final earnedSnapshot = await _firestore
        .collection('milestones')
        .where('userId', isEqualTo: userId)
        .get();

    final earnedBadges = earnedSnapshot.docs
        .map((doc) => doc.data()['badge'] as String?)
        .whereType<String>()
        .toSet();

    final upcoming = <MilestoneDef>[];

    // Find next streak milestone
    if (currentStreak != null) {
      for (final def in MilestoneDefinitions.streakMilestones) {
        if (!earnedBadges.contains(def.badge) && currentStreak < def.threshold) {
          upcoming.add(def);
          break;
        }
      }
    }

    // Find next workout milestone
    if (totalWorkouts != null) {
      for (final def in MilestoneDefinitions.workoutMilestones) {
        if (!earnedBadges.contains(def.badge) && totalWorkouts < def.threshold) {
          upcoming.add(def);
          break;
        }
      }
    }

    // Find next weight milestone
    if (totalWeightLost != null && totalWeightLost > 0) {
      for (final def in MilestoneDefinitions.weightMilestones) {
        if (def.badge.contains('lost') &&
            !earnedBadges.contains(def.badge) &&
            totalWeightLost < def.threshold) {
          upcoming.add(def);
          break;
        }
      }
    }

    return upcoming;
  }
}
