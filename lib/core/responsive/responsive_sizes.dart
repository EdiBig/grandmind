import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Responsive component sizes that scale with screen size
class ResponsiveSizes {
  final BuildContext context;
  late final ResponsiveHelper _responsive;

  ResponsiveSizes(this.context) {
    _responsive = ResponsiveHelper(context);
  }

  // Scale factor for component sizes
  double get _scaleFactor {
    final width = _responsive.screenWidth;
    if (width < 375) return 0.85;
    if (width < 414) return 1.0;
    if (width < 480) return 1.1;
    if (width < 768) return 1.2;
    if (width < 1024) return 1.3;
    return 1.4;
  }

  // Readiness Ring sizes
  double get readinessRingSize {
    final width = _responsive.screenWidth;
    if (width < 375) return 160;
    if (width < 414) return 180;
    if (width < 480) return 200;
    if (width < 768) return 220;
    return 260;
  }

  double get readinessRingStroke {
    final width = _responsive.screenWidth;
    if (width < 375) return 8;
    if (width < 414) return 10;
    if (width < 768) return 12;
    return 14;
  }

  // Button sizes
  double get buttonHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 44;
    if (width < 414) return 48;
    if (width < 768) return 52;
    return 56;
  }

  double get buttonMinWidth {
    final width = _responsive.screenWidth;
    if (width < 375) return 100;
    if (width < 414) return 120;
    if (width < 768) return 140;
    return 160;
  }

  double get buttonBorderRadius {
    final width = _responsive.screenWidth;
    if (width < 375) return 10;
    if (width < 414) return 12;
    if (width < 768) return 14;
    return 16;
  }

  // Icon sizes
  double get iconSmall => 16 * _scaleFactor;
  double get iconMedium => 20 * _scaleFactor;
  double get iconLarge => 24 * _scaleFactor;
  double get iconXLarge => 32 * _scaleFactor;

  // Quick action sizes
  double get quickActionIconSize {
    final width = _responsive.screenWidth;
    if (width < 375) return 20;
    if (width < 414) return 24;
    if (width < 768) return 28;
    return 32;
  }

  double get quickActionSize {
    final width = _responsive.screenWidth;
    if (width < 375) return 56;
    if (width < 414) return 64;
    if (width < 768) return 72;
    return 80;
  }

  // Card sizes
  double get cardBorderRadius {
    final width = _responsive.screenWidth;
    if (width < 375) return 12;
    if (width < 414) return 16;
    if (width < 768) return 20;
    return 24;
  }

  double get bentoCardMinHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 100;
    if (width < 414) return 110;
    if (width < 768) return 130;
    return 150;
  }

  // Avatar sizes
  double get avatarSmall => 32 * _scaleFactor;
  double get avatarMedium => 40 * _scaleFactor;
  double get avatarLarge => 56 * _scaleFactor;
  double get avatarXLarge => 80 * _scaleFactor;

  // Navigation
  double get bottomNavHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 60;
    if (width < 414) return 65;
    if (width < 768) return 70;
    return 80;
  }

  double get bottomNavIconSize {
    final width = _responsive.screenWidth;
    if (width < 375) return 22;
    if (width < 414) return 24;
    if (width < 768) return 26;
    return 28;
  }

  // App bar
  double get appBarHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 56;
    if (width < 414) return 60;
    if (width < 768) return 64;
    return 72;
  }

  // Input fields
  double get inputHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 44;
    if (width < 414) return 48;
    if (width < 768) return 52;
    return 56;
  }

  double get inputBorderRadius {
    final width = _responsive.screenWidth;
    if (width < 375) return 8;
    if (width < 414) return 10;
    if (width < 768) return 12;
    return 14;
  }

  // Charts and graphs
  double get chartHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 180;
    if (width < 414) return 200;
    if (width < 768) return 250;
    return 300;
  }

  double get chartBarWidth {
    final width = _responsive.screenWidth;
    if (width < 375) return 6;
    if (width < 414) return 8;
    if (width < 768) return 12;
    return 16;
  }

  // Workout card specific
  double get workoutCardHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 140;
    if (width < 414) return 160;
    if (width < 768) return 180;
    return 200;
  }

  // Insight card
  double get insightCardHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 80;
    if (width < 414) return 90;
    if (width < 768) return 100;
    return 110;
  }

  // Modal/Bottom sheet
  double get bottomSheetBorderRadius {
    final width = _responsive.screenWidth;
    if (width < 375) return 20;
    if (width < 414) return 24;
    if (width < 768) return 28;
    return 32;
  }

  double get maxBottomSheetWidth {
    if (_responsive.isTablet || _responsive.isLargeTablet) {
      return 600;
    }
    return double.infinity;
  }

  // List items
  double get listItemHeight {
    final width = _responsive.screenWidth;
    if (width < 375) return 56;
    if (width < 414) return 64;
    if (width < 768) return 72;
    return 80;
  }

  // Divider
  double get dividerThickness {
    final width = _responsive.screenWidth;
    if (width < 768) return 0.5;
    return 1.0;
  }
}
