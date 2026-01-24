import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Helper class for responsive design calculations
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  // Screen dimensions
  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  double get shortestSide => MediaQuery.of(context).size.shortestSide;
  double get longestSide => MediaQuery.of(context).size.longestSide;

  // Device type detection
  DeviceType get deviceType {
    if (screenWidth < ScreenBreakpoints.mobileSmall) return DeviceType.mobileSmall;
    if (screenWidth < ScreenBreakpoints.mobileMedium) return DeviceType.mobileMedium;
    if (screenWidth < ScreenBreakpoints.mobileLarge) return DeviceType.mobileLarge;
    if (screenWidth < ScreenBreakpoints.tabletSmall) return DeviceType.tabletSmall;
    if (screenWidth < ScreenBreakpoints.tabletMedium) return DeviceType.tabletMedium;
    return DeviceType.tabletLarge;
  }

  // Quick checks
  bool get isMobile => screenWidth < ScreenBreakpoints.mobileLarge;
  bool get isMobileSmall => screenWidth < ScreenBreakpoints.mobileSmall;
  bool get isTablet => screenWidth >= ScreenBreakpoints.mobileLarge && screenWidth < ScreenBreakpoints.tabletMedium;
  bool get isLargeTablet => screenWidth >= ScreenBreakpoints.tabletMedium;
  bool get isPortrait => screenHeight > screenWidth;
  bool get isLandscape => screenWidth > screenHeight;

  // Safe areas
  EdgeInsets get safeAreaPadding => MediaQuery.of(context).padding;
  double get topSafeArea => MediaQuery.of(context).padding.top;
  double get bottomSafeArea => MediaQuery.of(context).padding.bottom;
  double get leftSafeArea => MediaQuery.of(context).padding.left;
  double get rightSafeArea => MediaQuery.of(context).padding.right;

  // Responsive values
  double responsiveWidth(double percentage) => screenWidth * (percentage / 100);
  double responsiveHeight(double percentage) => screenHeight * (percentage / 100);

  // Adaptive value based on device type
  T adaptive<T>({
    required T mobile,
    T? mobileLarge,
    T? tablet,
    T? tabletLarge,
  }) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobileMedium:
        return mobile;
      case DeviceType.mobileLarge:
        return mobileLarge ?? mobile;
      case DeviceType.tabletSmall:
      case DeviceType.tabletMedium:
        return tablet ?? mobileLarge ?? mobile;
      case DeviceType.tabletLarge:
        return tabletLarge ?? tablet ?? mobileLarge ?? mobile;
    }
  }

  // Column count for grids
  int get gridColumnCount {
    if (screenWidth < ScreenBreakpoints.mobileLarge) return 2;  // Mobile: 2 columns
    if (screenWidth < ScreenBreakpoints.tabletSmall) return 3;  // Small tablet: 3 columns
    if (screenWidth < ScreenBreakpoints.tabletMedium) return 4; // Medium tablet: 4 columns
    return 6;                                                    // Large tablet: 6 columns
  }

  // Bento grid columns for home screen
  int get bentoColumnCount {
    if (screenWidth < ScreenBreakpoints.mobileLarge) return 2;  // Mobile: 2 columns
    if (screenWidth < ScreenBreakpoints.tabletSmall) return 3;  // Small tablet: 3 columns
    if (screenWidth < ScreenBreakpoints.tabletMedium) return 4; // Medium tablet: 4 columns
    return 4;                                                    // Large tablet: 4 columns (max)
  }

  // Quick action card count per row
  int get quickActionCount {
    if (screenWidth < ScreenBreakpoints.mobileLarge) return 5;  // Mobile: horizontal scroll
    if (screenWidth < ScreenBreakpoints.tabletSmall) return 6;
    return 7;
  }
}
