import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Responsive spacing system that scales with screen size
class ResponsiveSpacing {
  final BuildContext context;
  late final ResponsiveHelper _responsive;

  ResponsiveSpacing(this.context) {
    _responsive = ResponsiveHelper(context);
  }

  // Base unit scales with screen width
  double get _baseUnit {
    final width = _responsive.screenWidth;
    if (width < 375) return 3.5;     // Small phones: 3.5px base
    if (width < 414) return 4.0;     // Standard phones: 4px base
    if (width < 480) return 4.5;     // Large phones: 4.5px base
    if (width < 768) return 5.0;     // Small tablets: 5px base
    if (width < 1024) return 5.5;    // Medium tablets: 5.5px base
    return 6.0;                       // Large tablets: 6px base
  }

  // Spacing values (multiples of base unit)
  double get xs => _baseUnit;         // 4px standard
  double get sm => _baseUnit * 2;     // 8px standard
  double get md => _baseUnit * 3;     // 12px standard
  double get lg => _baseUnit * 4;     // 16px standard
  double get xl => _baseUnit * 5;     // 20px standard
  double get xxl => _baseUnit * 6;    // 24px standard
  double get xxxl => _baseUnit * 8;   // 32px standard

  // Screen padding (horizontal margins)
  double get screenPadding {
    final width = _responsive.screenWidth;
    if (width < 375) return 12;       // Small phones
    if (width < 414) return 16;       // Standard phones
    if (width < 480) return 20;       // Large phones
    if (width < 768) return 24;       // Small tablets
    if (width < 1024) return 32;      // Medium tablets
    return 48;                         // Large tablets
  }

  // Card padding
  double get cardPadding {
    final width = _responsive.screenWidth;
    if (width < 375) return 12;
    if (width < 414) return 16;
    if (width < 768) return 20;
    return 24;
  }

  // Section spacing (vertical space between sections)
  double get sectionSpacing {
    final width = _responsive.screenWidth;
    if (width < 375) return 20;
    if (width < 414) return 24;
    if (width < 768) return 32;
    return 40;
  }

  // Grid spacing
  double get gridSpacing {
    final width = _responsive.screenWidth;
    if (width < 375) return 8;
    if (width < 414) return 12;
    if (width < 768) return 16;
    return 20;
  }

  // EdgeInsets helpers
  EdgeInsets get screenHorizontal => EdgeInsets.symmetric(horizontal: screenPadding);
  EdgeInsets get screenAll => EdgeInsets.all(screenPadding);
  EdgeInsets get cardAll => EdgeInsets.all(cardPadding);

  EdgeInsets get cardHorizontal => EdgeInsets.symmetric(
    horizontal: cardPadding,
    vertical: cardPadding * 0.75,
  );

  EdgeInsets symmetric({double? horizontal, double? vertical}) => EdgeInsets.symmetric(
    horizontal: horizontal ?? 0,
    vertical: vertical ?? 0,
  );

  // SizedBox helpers for spacing
  SizedBox get verticalXs => SizedBox(height: xs);
  SizedBox get verticalSm => SizedBox(height: sm);
  SizedBox get verticalMd => SizedBox(height: md);
  SizedBox get verticalLg => SizedBox(height: lg);
  SizedBox get verticalXl => SizedBox(height: xl);
  SizedBox get verticalXxl => SizedBox(height: xxl);
  SizedBox get verticalSection => SizedBox(height: sectionSpacing);

  SizedBox get horizontalXs => SizedBox(width: xs);
  SizedBox get horizontalSm => SizedBox(width: sm);
  SizedBox get horizontalMd => SizedBox(width: md);
  SizedBox get horizontalLg => SizedBox(width: lg);
  SizedBox get horizontalXl => SizedBox(width: xl);
  SizedBox get horizontalXxl => SizedBox(width: xxl);
}
