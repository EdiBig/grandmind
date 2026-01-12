import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/mood_energy_repository.dart';
import '../../domain/models/energy_log.dart';

final todayEnergyLogsProvider = FutureProvider<List<EnergyLog>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  final repository = ref.watch(moodEnergyRepositoryProvider);
  return repository.getLogsInRange(userId, start, end);
});
