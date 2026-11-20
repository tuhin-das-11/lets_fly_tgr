import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, destructive }

/// Premium tactile button with loading indicator and icon support.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height = 52.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(color: colorScheme.outline, width: 1.5);
        break;
      case AppButtonVariant.destructive:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: foregroundColor),
            const SizedBox(width: AppSpacing.space8),
          ],
          Text(
            text,
            style: AppTypography.labelLarge.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final buttonWidget = SizedBox(
      height: height,
      child: Material(
        color: onPressed == null ? backgroundColor.withOpacity(0.5) : backgroundColor,
        borderRadius: AppSpacing.roundedMd,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppSpacing.roundedMd,
          child: Container(
            decoration: BoxDecoration(
              border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
              borderRadius: AppSpacing.roundedMd,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }
}
