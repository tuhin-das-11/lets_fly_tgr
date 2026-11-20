import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Adaptive builder widget that provides distinct layouts for Compact (Mobile),
/// Medium (Tablet), and Expanded (Desktop/Windows) viewport sizes.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.breakpointMedium) {
          return expanded ?? medium ?? compact;
        } else if (constraints.maxWidth >= AppConstants.breakpointCompact) {
          return medium ?? compact;
        }
        return compact;
      },
    );
  }
}
