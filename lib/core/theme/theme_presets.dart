import 'package:flutter/material.dart';

class ThemePreset {
  final String id;
  final String name;
  final Color seedColor;
  final Color accentColor;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.seedColor,
    required this.accentColor,
  });
}

class ThemePresets {
  ThemePresets._();

  static const ThemePreset sunrise = ThemePreset(
    id: 'sunrise',
    name: 'Sunrise',
    seedColor: Color(0xFFF97316),
    accentColor: Color(0xFFFB7185),
  );

  static const ThemePreset ocean = ThemePreset(
    id: 'ocean',
    name: 'Ocean',
    seedColor: Color(0xFF0EA5E9),
    accentColor: Color(0xFF14B8A6),
  );

  static const ThemePreset forest = ThemePreset(
    id: 'forest',
    name: 'Forest',
    seedColor: Color(0xFF16A34A),
    accentColor: Color(0xFF84CC16),
  );

  static const ThemePreset canyon = ThemePreset(
    id: 'canyon',
    name: 'Canyon',
    seedColor: Color(0xFFF59E0B),
    accentColor: Color(0xFFEA580C),
  );

  static const ThemePreset slate = ThemePreset(
    id: 'slate',
    name: 'Slate',
    seedColor: Color(0xFF475569),
    accentColor: Color(0xFF94A3B8),
  );

  static const List<ThemePreset> all = [
    sunrise,
    ocean,
    forest,
    canyon,
    slate,
  ];

  static ThemePreset byId(String? id) {
    if (id == null) return sunrise;
    return all.firstWhere(
      (preset) => preset.id == id,
      orElse: () => sunrise,
    );
  }
}
