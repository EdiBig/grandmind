import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinesa/core/providers/shared_preferences_provider.dart';
import '../../domain/models/fitness_profile.dart';

final fitnessProfileProvider =
    StateNotifierProvider<FitnessProfileNotifier, FitnessProfile>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FitnessProfileNotifier(prefs);
});

class FitnessProfileNotifier extends StateNotifier<FitnessProfile> {
  FitnessProfileNotifier(this._prefs) : super(_load(_prefs));

  static const _prefsKey = 'fitness_profile_v1';
  final SharedPreferences _prefs;

  void update(FitnessProfile profile) {
    state = profile;
    _prefs.setString(_prefsKey, jsonEncode(profile.toJson()));
  }

  void clear() {
    update(const FitnessProfile());
  }

  static FitnessProfile _load(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return const FitnessProfile();
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return FitnessProfile.fromJson(data);
    } catch (_) {
      return const FitnessProfile();
    }
  }
}
