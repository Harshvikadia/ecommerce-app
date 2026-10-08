import 'package:flutter/material.dart';

/// Screen size ka helper. Use: final sc = SizeConfig.of(context);
class SizeConfig {
  final Size size;

  const SizeConfig._(this.size);

  // sizeOf: sirf size badalne par rebuild (keyboard khulne par nahi)
  factory SizeConfig.of(BuildContext context) =>
      SizeConfig._(MediaQuery.sizeOf(context));

  double get width => size.width;
  double get height => size.height;
  double get shortest => size.shortestSide;

  // Breakpoints
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;
  bool get isLandscape => width > height;

  // Percentage helpers: sc.w(0.5) = width ka 50%
  double w(double percent) => width * percent;
  double h(double percent) => height * percent;

  // Common spacing
  double get hPadding => shortest * 0.06;
  double get gap => height * 0.025;

  // Form ya content bahut chaura na ho jaye
  double get contentMaxWidth => width > 500 ? 420 : width;

  // Button height: 48 se 56 ke beech (touch target chhota na ho)
  double get buttonHeight => (height * 0.07).clamp(48.0, 56.0);

  // Grid columns screen ke hisaab se
  int get gridColumns {
    if (width >= 1024) return 4;
    if (width >= 600) return 3;
    return 2;
  }
}