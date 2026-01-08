import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _favoriteKey = 'workout_library_favorites';

final workoutLibraryFavoritesProvider =
    StateNotifierProvider<WorkoutLibraryFavoritesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WorkoutLibraryFavoritesNotifier(prefs);
});

class WorkoutLibraryFavoritesNotifier extends StateNotifier<Set<String>> {
  WorkoutLibraryFavoritesNotifier(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static Set<String> _load(SharedPreferences prefs) {
    return prefs.getStringList(_favoriteKey)?.toSet() ?? <String>{};
  }

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggleFavorite(String id) async {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _prefs.setStringList(_favoriteKey, next.toList());
  }
}
