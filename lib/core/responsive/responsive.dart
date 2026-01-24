// Responsive design utilities for cross-device compatibility
//
// Usage:
// import 'package:grandmind/core/responsive/responsive.dart';
//
// Using extensions (recommended):
//   context.responsive.isMobile
//   context.spacing.screenPadding
//   context.sizes.buttonHeight
//   context.textStyles.headlineLarge
//
// Using builder widget:
//   ResponsiveBuilder(
//     builder: (context, responsive) {
//       return Text(responsive.isMobile ? 'Mobile' : 'Tablet');
//     },
//   )
//
// Using layout widget:
//   ResponsiveLayout(
//     mobile: MobileLayout(),
//     tablet: TabletLayout(),
//   )

export 'responsive_breakpoints.dart';
export 'responsive_helper.dart';
export 'responsive_extensions.dart';
export 'responsive_spacing.dart';
export 'responsive_sizes.dart';
export 'responsive_text_styles.dart';
export 'responsive_builder.dart';
export 'max_width_container.dart';
export 'safe_area_wrapper.dart';
