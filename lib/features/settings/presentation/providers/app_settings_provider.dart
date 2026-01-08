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

  const AppSettingsState({
    required this.themeMode,
    required this.themePresetId,
    required this.offlineMode,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? themePresetId,
    bool? offlineMode,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      themePresetId: themePresetId ?? this.themePresetId,
      offlineMode: offlineMode ?? this.offlineMode,
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
    final presetId = prefs.getString('theme_preset') ?? ThemePresets.sunrise.id;
    final offlineMode = prefs.getBool('offline_mode') ?? false;

    return AppSettingsState(
      themeMode: themeMode,
      themePresetId: presetId,
      offlineMode: offlineMode,
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
      default:
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
