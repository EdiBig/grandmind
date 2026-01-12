import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kinesa/core/providers/shared_preferences_provider.dart';
import 'package:kinesa/core/theme/theme_presets.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final String themePresetId;
  final bool offlineMode;
  final bool workoutsEnabled;
  final bool habitsEnabled;
  final bool moodEnergyEnabled;
  final bool nutritionEnabled;
  final bool sleepEnabled;
  final String language;

  const AppSettingsState({
    required this.themeMode,
    required this.themePresetId,
    required this.offlineMode,
    required this.workoutsEnabled,
    required this.habitsEnabled,
    required this.moodEnergyEnabled,
    required this.nutritionEnabled,
    required this.sleepEnabled,
    required this.language,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? themePresetId,
    bool? offlineMode,
    bool? workoutsEnabled,
    bool? habitsEnabled,
    bool? moodEnergyEnabled,
    bool? nutritionEnabled,
    bool? sleepEnabled,
    String? language,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      themePresetId: themePresetId ?? this.themePresetId,
      offlineMode: offlineMode ?? this.offlineMode,
      workoutsEnabled: workoutsEnabled ?? this.workoutsEnabled,
      habitsEnabled: habitsEnabled ?? this.habitsEnabled,
      moodEnergyEnabled: moodEnergyEnabled ?? this.moodEnergyEnabled,
      nutritionEnabled: nutritionEnabled ?? this.nutritionEnabled,
      sleepEnabled: sleepEnabled ?? this.sleepEnabled,
      language: language ?? this.language,
    );
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppSettingsNotifier(prefs: prefs);
});

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(_loadFromPrefs(prefs)) {
    _syncOfflineMode(state.offlineMode);
  }

  final SharedPreferences _prefs;

  static AppSettingsState _loadFromPrefs(SharedPreferences prefs) {
    final themeMode = _themeModeFromString(prefs.getString('theme_mode'));
    final presetId =
        prefs.getString('theme_preset') ?? ThemePresets.kinesa.id;
    final offlineMode = prefs.getBool('offline_mode') ?? false;
    final workoutsEnabled = prefs.getBool('module_workouts') ?? true;
    final habitsEnabled = prefs.getBool('module_habits') ?? true;
    final moodEnergyEnabled = prefs.getBool('module_mood_energy') ?? true;
    final nutritionEnabled = prefs.getBool('module_nutrition') ?? true;
    final sleepEnabled = prefs.getBool('module_sleep') ?? true;
    final language = prefs.getString('language') ?? 'English (UK)';

    return AppSettingsState(
      themeMode: themeMode,
      themePresetId: presetId,
      offlineMode: offlineMode,
      workoutsEnabled: workoutsEnabled,
      habitsEnabled: habitsEnabled,
      moodEnergyEnabled: moodEnergyEnabled,
      nutritionEnabled: nutritionEnabled,
      sleepEnabled: sleepEnabled,
      language: language,
    );
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString('theme_mode', _themeModeToString(mode));
  }

  Future<void> setThemePreset(ThemePreset preset) async {
    state = state.copyWith(themePresetId: preset.id);
    await _prefs.setString('theme_preset', preset.id);
  }

  Future<void> setOfflineMode(bool enabled) async {
    state = state.copyWith(offlineMode: enabled);
    await _prefs.setBool('offline_mode', enabled);
    await _syncOfflineMode(enabled);
  }

  Future<void> setModuleEnabled(AppModule module, bool enabled) async {
    switch (module) {
      case AppModule.workouts:
        state = state.copyWith(workoutsEnabled: enabled);
        await _prefs.setBool('module_workouts', enabled);
        return;
      case AppModule.habits:
        state = state.copyWith(habitsEnabled: enabled);
        await _prefs.setBool('module_habits', enabled);
        return;
      case AppModule.moodEnergy:
        state = state.copyWith(moodEnergyEnabled: enabled);
        await _prefs.setBool('module_mood_energy', enabled);
        return;
      case AppModule.nutrition:
        state = state.copyWith(nutritionEnabled: enabled);
        await _prefs.setBool('module_nutrition', enabled);
        return;
      case AppModule.sleep:
        state = state.copyWith(sleepEnabled: enabled);
        await _prefs.setBool('module_sleep', enabled);
        return;
    }
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await _prefs.setString('language', language);
  }

  Future<void> _syncOfflineMode(bool enabled) async {
    try {
      if (enabled) {
        await FirebaseFirestore.instance.disableNetwork();
      } else {
        await FirebaseFirestore.instance.enableNetwork();
      }
    } catch (_) {
      // Ignore Firestore network toggle errors; preference still saved.
    }
  }
}

enum AppModule {
  workouts,
  habits,
  moodEnergy,
  nutrition,
  sleep,
}
