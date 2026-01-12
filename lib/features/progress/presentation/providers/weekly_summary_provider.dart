import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../habits/data/repositories/habit_repository.dart';
import '../../../habits/domain/models/habit_log.dart';
import '../../../mood_energy/data/repositories/mood_energy_repository.dart';
import '../../../mood_energy/domain/models/energy_log.dart';

class WeeklySummaryRange {
  final DateTime start;
  final DateTime end;

  const WeeklySummaryRange({
    required this.start,
    required this.end,
  });

  factory WeeklySummaryRange.current() {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 23, 59, 59, 999)
            .add(const Duration(days: 6));

    return WeeklySummaryRange(start: startOfWeek, end: endOfWeek);
  }

  WeeklySummaryRange previousWeek() {
    final previousStart = start.subtract(const Duration(days: 7));
    final previousEnd = end.subtract(const Duration(days: 7));
    return WeeklySummaryRange(start: previousStart, end: previousEnd);
  }
}

final weeklySummaryRangeProvider = Provider<WeeklySummaryRange>((ref) {
  return WeeklySummaryRange.current();
});

final weeklyHabitLogsProvider = FutureProvider<List<HabitLog>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final range = ref.watch(weeklySummaryRangeProvider);
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getUserHabitLogsInRange(userId, range.start, range.end);
});

final weeklyEnergyLogsProvider = FutureProvider<List<EnergyLog>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final range = ref.watch(weeklySummaryRangeProvider);
  final repository = ref.watch(moodEnergyRepositoryProvider);
  return repository.getLogsInRange(userId, range.start, range.end);
});

final previousWeeklyEnergyLogsProvider =
    FutureProvider<List<EnergyLog>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final range = ref.watch(weeklySummaryRangeProvider).previousWeek();
  final repository = ref.watch(moodEnergyRepositoryProvider);
  return repository.getLogsInRange(userId, range.start, range.end);
});
