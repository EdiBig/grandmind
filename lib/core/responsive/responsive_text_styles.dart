import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Responsive typography that scales with screen size
class ResponsiveTextStyles {
  final BuildContext context;
  late final ResponsiveHelper _responsive;

  ResponsiveTextStyles(this.context) {
    _responsive = ResponsiveHelper(context);
  }

  // Scale factor based on screen width
  double get _scaleFactor {
    final width = _responsive.screenWidth;
    if (width < 375) return 0.85;      // Small phones: 85%
    if (width < 414) return 1.0;       // Standard phones: 100%
    if (width < 480) return 1.05;      // Large phones: 105%
    if (width < 768) return 1.1;       // Small tablets: 110%
    if (width < 1024) return 1.15;     // Medium tablets: 115%
    return 1.2;                         // Large tablets: 120%
  }

  // Responsive font sizes
  double get displayLarge => 48 * _scaleFactor;   // Hero numbers
  double get displayMedium => 36 * _scaleFactor;  // Section titles
  double get displaySmall => 28 * _scaleFactor;   // Card titles
  double get headlineLarge => 24 * _scaleFactor;  // Page titles
  double get headlineMedium => 20 * _scaleFactor; // Subsection titles
  double get headlineSmall => 18 * _scaleFactor;  // Card headers
  double get titleLarge => 16 * _scaleFactor;     // List item titles
  double get titleMedium => 14 * _scaleFactor;    // Button text
  double get titleSmall => 12 * _scaleFactor;     // Captions
  double get bodyLarge => 16 * _scaleFactor;      // Body text
  double get bodyMedium => 14 * _scaleFactor;     // Secondary text
  double get bodySmall => 12 * _scaleFactor;      // Helper text
  double get labelLarge => 14 * _scaleFactor;     // Labels
  double get labelMedium => 12 * _scaleFactor;    // Small labels
  double get labelSmall => 10 * _scaleFactor;     // Tiny labels

  // Pre-built text styles
  TextStyle get heroScore => TextStyle(
    fontSize: displayLarge,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  TextStyle get sectionTitle => TextStyle(
    fontSize: headlineMedium,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  TextStyle get cardTitle => TextStyle(
    fontSize: titleLarge,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  TextStyle get cardValue => TextStyle(
    fontSize: headlineLarge,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  TextStyle get bodyText => TextStyle(
    fontSize: bodyMedium,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF94A3B8),
  );

  TextStyle get caption => TextStyle(
    fontSize: labelMedium,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF6B7280),
  );

  TextStyle get buttonText => TextStyle(
    fontSize: titleMedium,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
