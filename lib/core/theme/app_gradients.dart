import 'package:flutter/material.dart';

class AppGradients extends ThemeExtension<AppGradients> {
  final LinearGradient primary;
  final LinearGradient secondary;
  final LinearGradient accent;

  const AppGradients({
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  factory AppGradients.fromScheme(ColorScheme scheme) {
    return AppGradients(
      primary: LinearGradient(
        colors: [
          scheme.primary,
          scheme.secondary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      secondary: LinearGradient(
        colors: [
          scheme.secondary,
          scheme.tertiary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: LinearGradient(
        colors: [
          scheme.tertiary,
          scheme.primary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  @override
  AppGradients copyWith({
    LinearGradient? primary,
    LinearGradient? secondary,
    LinearGradient? accent,
  }) {
    return AppGradients(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(
      primary: LinearGradient.lerp(primary, other.primary, t) ?? primary,
      secondary: LinearGradient.lerp(secondary, other.secondary, t) ?? secondary,
      accent: LinearGradient.lerp(accent, other.accent, t) ?? accent,
    );
  }
}
