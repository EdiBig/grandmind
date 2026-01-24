/// Device breakpoints and screen categories for responsive design
enum DeviceType {
  mobileSmall,   // < 375px
  mobileMedium,  // 375-414px
  mobileLarge,   // 415-480px
  tabletSmall,   // 481-768px
  tabletMedium,  // 769-1024px
  tabletLarge,   // > 1024px
}

enum ScreenOrientation {
  portrait,
  landscape,
}

/// Screen width breakpoints in logical pixels
class ScreenBreakpoints {
  ScreenBreakpoints._();

  static const double mobileSmall = 375;
  static const double mobileMedium = 414;
  static const double mobileLarge = 480;
  static const double tabletSmall = 768;
  static const double tabletMedium = 1024;
  static const double tabletLarge = 1200;
}
