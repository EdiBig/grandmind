import 'package:flutter/material.dart';
import 'responsive_helper.dart';
import 'responsive_spacing.dart';

/// Wrapper that handles safe areas with responsive padding
class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final bool addScreenPadding;
  final EdgeInsetsGeometry? additionalPadding;
  final Color? backgroundColor;

  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.addScreenPadding = false,
    this.additionalPadding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );

    if (addScreenPadding) {
      final spacing = ResponsiveSpacing(context);
      content = Padding(
        padding: spacing.screenHorizontal,
        child: content,
      );
    }

    if (additionalPadding != null) {
      content = Padding(
        padding: additionalPadding!,
        child: content,
      );
    }

    if (backgroundColor != null) {
      return ColoredBox(
        color: backgroundColor!,
        child: content,
      );
    }

    return content;
  }
}

/// Screen wrapper with consistent padding, safe areas, and optional scroll
class ResponsiveScreen extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final ScrollController? scrollController;
  final bool useSafeArea;
  final bool useScreenPadding;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const ResponsiveScreen({
    super.key,
    required this.child,
    this.scrollable = true,
    this.scrollController,
    this.useSafeArea = true,
    this.useScreenPadding = true,
    this.padding,
    this.backgroundColor,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveSpacing(context);

    Widget content = child;

    // Add padding
    if (useScreenPadding || padding != null) {
      final effectivePadding = padding ?? spacing.screenHorizontal;
      content = Padding(padding: effectivePadding, child: content);
    }

    // Make scrollable if needed
    if (scrollable) {
      content = SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    // Add safe area if no app bar (app bar handles top safe area)
    if (useSafeArea && appBar == null) {
      content = SafeArea(child: content);
    } else if (useSafeArea) {
      content = SafeArea(top: false, child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Tab screen wrapper optimized for bottom navigation views
class ResponsiveTabScreen extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final ScrollController? scrollController;
  final bool addTopPadding;
  final EdgeInsetsGeometry? padding;
  final RefreshCallback? onRefresh;

  const ResponsiveTabScreen({
    super.key,
    required this.child,
    this.scrollable = true,
    this.scrollController,
    this.addTopPadding = true,
    this.padding,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveSpacing(context);
    final responsive = ResponsiveHelper(context);

    Widget content = child;

    // Add responsive horizontal padding
    final effectivePadding = padding ?? spacing.screenHorizontal;
    content = Padding(padding: effectivePadding, child: content);

    // Add top safe area padding on mobile
    if (addTopPadding) {
      content = Padding(
        padding: EdgeInsets.only(top: responsive.topSafeArea + spacing.md),
        child: content,
      );
    }

    // Make scrollable with optional refresh
    if (scrollable) {
      if (onRefresh != null) {
        content = RefreshIndicator(
          onRefresh: onRefresh!,
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: content,
          ),
        );
      } else {
        content = SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        );
      }
    }

    return content;
  }
}
