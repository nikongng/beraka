import 'package:flutter/material.dart';

/// =========================================================
/// Responsive Helper
///
/// Mobile  : < 600
/// Tablet  : 600 - 1023
/// Desktop : >= 1024
/// =========================================================

class Responsive {
  Responsive._();

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return width >= mobileBreakpoint &&
        width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        tabletBreakpoint;
  }

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1320;
    if (isTablet(context)) return 900;
    return width(context);
  }

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48;

    if (isTablet(context)) return 32;

    return 20;
  }

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;

    if (isTablet(context)) return 2;

    return 1;
  }

  static double sectionSpacing(BuildContext context) {
    if (isDesktop(context)) return 80;

    if (isTablet(context)) return 60;

    return 40;
  }

  static double heroHeight(BuildContext context) {
    if (isDesktop(context)) return 720;

    if (isTablet(context)) return 560;

    return 420;
  }

  static double titleSize(BuildContext context) {
    if (isDesktop(context)) return 52;

    if (isTablet(context)) return 42;

    return 32;
  }

  static double subtitleSize(BuildContext context) {
    if (isDesktop(context)) return 20;

    if (isTablet(context)) return 18;

    return 16;
  }

  static double cardWidth(BuildContext context) {
    if (isDesktop(context)) return 320;

    if (isTablet(context)) return 280;

    return double.infinity;
  }
}

/// =========================================================
/// Responsive Builder
///
/// Utilisation :
///
/// ResponsiveBuilder(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(),
///   desktop: DesktopWidget(),
/// )
/// =========================================================

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }

    if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    }

    return mobile;
  }
}

/// =========================================================
/// Responsive Container
///
/// Centre automatiquement le contenu
/// sur les grands écrans.
/// =========================================================

class ResponsiveContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                Responsive.horizontalPadding(context),
          ),
          child: child,
        ),
      ),
    );
  }
}