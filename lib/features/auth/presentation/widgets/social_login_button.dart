import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

enum SocialProvider { google, phone }

/// Tactile branded social login trigger button.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGoogle = provider == SocialProvider.google;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        side: BorderSide(color: theme.colorScheme.outline, width: 1.2),
        backgroundColor: theme.colorScheme.surface,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGoogle ? Icons.g_mobiledata_rounded : Icons.phone_android_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: AppSpacing.space12),
                Text(
                  isGoogle ? 'Continue with Google' : 'Continue with Phone',
                  style: AppTypography.labelLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
