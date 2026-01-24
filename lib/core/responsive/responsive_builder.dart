import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';
import 'responsive_helper.dart';

/// Widget that rebuilds with responsive context when screen size changes
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper responsive) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper(context);
        return builder(context, responsive);
      },
    );
  }
}

/// Widget that shows different layouts based on device type
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? mobileLarge;
  final Widget? tablet;
  final Widget? tabletLarge;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.mobileLarge,
    this.tablet,
    this.tabletLarge,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper(context);

        switch (responsive.deviceType) {
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
      },
    );
  }
}

/// Widget that shows different values based on orientation
class OrientationLayout extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationLayout({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.landscape && landscape != null) {
          return landscape!;
        }
        return portrait;
      },
    );
  }
}

/// Widget that provides responsive value based on device type
class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? mobileLarge;
  final T? tablet;
  final T? tabletLarge;
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.mobileLarge,
    this.tablet,
    this.tabletLarge,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final value = responsive.adaptive<T>(
      mobile: mobile,
      mobileLarge: mobileLarge,
      tablet: tablet,
      tabletLarge: tabletLarge,
    );
    return builder(context, value);
  }
}
