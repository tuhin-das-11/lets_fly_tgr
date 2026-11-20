import 'package:flutter/material.dart';

/// 4-point geometric spacing tokens for pixel-perfect layout alignment.
abstract class AppSpacing {
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Corner Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Border Radii
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(radiusFull));

  // Common Insets
  static const EdgeInsets insetAll16 = EdgeInsets.all(space16);
  static const EdgeInsets insetAll20 = EdgeInsets.all(space20);
  static const EdgeInsets insetAll24 = EdgeInsets.all(space24);
  static const EdgeInsets insetH16V12 = EdgeInsets.symmetric(horizontal: space16, vertical: space12);
  static const EdgeInsets insetScreen = EdgeInsets.symmetric(horizontal: space20, vertical: space16);
}
