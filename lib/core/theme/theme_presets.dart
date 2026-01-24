import 'package:flutter/material.dart';

class ThemePreset {
  final String id;
  final String name;
  final String description;
  final Color seedColor;
  final Color accentColor;
  final bool isAmoled;
  final IconData icon;

  const ThemePreset({
    required this.id,
    required this.name,
    this.description = '',
    required this.seedColor,
    required this.accentColor,
    this.isAmoled = false,
    this.icon = Icons.palette,
  });
}

class ThemePresets {
  ThemePresets._();

  static const ThemePreset kinesa = ThemePreset(
    id: 'kinesa',
    name: 'Kinesa',
    description: 'Default blue',
    seedColor: Color(0xFF2F7DD8),
    accentColor: Color(0xFF5AA5A1),
    icon: Icons.water_drop_rounded,
  );

  static const ThemePreset ocean = ThemePreset(
    id: 'ocean',
    name: 'Ocean',
    description: 'Cool & refreshing',
    seedColor: Color(0xFF0EA5E9),
    accentColor: Color(0xFF14B8A6),
    icon: Icons.waves_rounded,
  );

  static const ThemePreset forest = ThemePreset(
    id: 'forest',
    name: 'Forest',
    description: 'Natural & grounded',
    seedColor: Color(0xFF16A34A),
    accentColor: Color(0xFF84CC16),
    icon: Icons.park_rounded,
  );

  static const ThemePreset canyon = ThemePreset(
    id: 'canyon',
    name: 'Canyon',
    description: 'Warm & earthy',
    seedColor: Color(0xFFF59E0B),
    accentColor: Color(0xFFEA580C),
    icon: Icons.terrain_rounded,
  );

  static const ThemePreset slate = ThemePreset(
    id: 'slate',
    name: 'Slate',
    description: 'Minimal & focused',
    seedColor: Color(0xFF475569),
    accentColor: Color(0xFF94A3B8),
    icon: Icons.filter_b_and_w_rounded,
  );

  static const ThemePreset midnight = ThemePreset(
    id: 'midnight',
    name: 'Midnight',
    description: 'AMOLED black',
    seedColor: Color(0xFF2DD4BF),
    accentColor: Color(0xFF60A5FA),
    isAmoled: true,
    icon: Icons.nightlight_round,
  );

  static const ThemePreset sunset = ThemePreset(
    id: 'sunset',
    name: 'Sunset',
    description: 'Warm & energizing',
    seedColor: Color(0xFFFF7043),
    accentColor: Color(0xFFEC407A),
    icon: Icons.wb_twilight_rounded,
  );

  static const ThemePreset lavender = ThemePreset(
    id: 'lavender',
    name: 'Lavender',
    description: 'Soft & calming',
    seedColor: Color(0xFFB39DDB),
    accentColor: Color(0xFF90CAF9),
    icon: Icons.spa_rounded,
  );

  static const List<ThemePreset> all = [
    kinesa,
    ocean,
    forest,
    canyon,
    slate,
    midnight,
    sunset,
    lavender,
  ];

  static ThemePreset byId(String? id) {
    if (id == null || id == 'grandpoint') return kinesa;
    return all.firstWhere(
      (preset) => preset.id == id,
      orElse: () => kinesa,
    );
  }
}
