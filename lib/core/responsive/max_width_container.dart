import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Container that constrains width on larger screens for optimal readability
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    // Calculate max width based on screen size if not provided
    final effectiveMaxWidth = maxWidth ?? _getDefaultMaxWidth(responsive);

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      child: child,
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (center) {
      content = Center(child: content);
    }

    return content;
  }

  double _getDefaultMaxWidth(ResponsiveHelper responsive) {
    final width = responsive.screenWidth;
    if (width < 768) return double.infinity;  // Mobile: full width
    if (width < 1024) return 720;              // Small tablet: 720px max
    if (width < 1200) return 960;              // Medium tablet: 960px max
    return 1140;                                // Large tablet: 1140px max
  }
}

/// Scrollable container with max width constraint for content-heavy screens
class MaxWidthScrollView extends StatelessWidget {
  final List<Widget> children;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const MaxWidthScrollView({
    super.key,
    required this.children,
    this.maxWidth,
    this.padding,
    this.controller,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      child: MaxWidthContainer(
        maxWidth: maxWidth,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Two-column layout for tablets with optional sidebar
class ResponsiveTwoColumn extends StatelessWidget {
  final Widget mainContent;
  final Widget? sideContent;
  final double sideWidth;
  final bool showSideOnMobile;

  const ResponsiveTwoColumn({
    super.key,
    required this.mainContent,
    this.sideContent,
    this.sideWidth = 320,
    this.showSideOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    // On mobile, show only main content (or optionally side content below)
    if (responsive.isMobile) {
      if (showSideOnMobile && sideContent != null) {
        return Column(
          children: [
            Expanded(child: mainContent),
            sideContent!,
          ],
        );
      }
      return mainContent;
    }

    // On tablet/desktop, show side-by-side
    if (sideContent == null) {
      return mainContent;
    }

    return Row(
      children: [
        Expanded(child: mainContent),
        SizedBox(
          width: sideWidth,
          child: sideContent,
        ),
      ],
    );
  }
}
