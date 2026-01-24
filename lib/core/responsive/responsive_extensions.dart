import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';
import 'responsive_helper.dart';
import 'responsive_spacing.dart';
import 'responsive_sizes.dart';
import 'responsive_text_styles.dart';

/// Extension methods for easy responsive access
extension ResponsiveExtension on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
  ResponsiveSpacing get spacing => ResponsiveSpacing(this);
  ResponsiveSizes get sizes => ResponsiveSizes(this);
  ResponsiveTextStyles get textStyles => ResponsiveTextStyles(this);

  bool get isMobile => responsive.isMobile;
  bool get isMobileSmall => responsive.isMobileSmall;
  bool get isTablet => responsive.isTablet;
  bool get isLargeTablet => responsive.isLargeTablet;
  bool get isPortrait => responsive.isPortrait;
  bool get isLandscape => responsive.isLandscape;

  double get screenWidth => responsive.screenWidth;
  double get screenHeight => responsive.screenHeight;

  DeviceType get deviceType => responsive.deviceType;

  EdgeInsets get safeAreaPadding => responsive.safeAreaPadding;
  double get topSafeArea => responsive.topSafeArea;
  double get bottomSafeArea => responsive.bottomSafeArea;
}
