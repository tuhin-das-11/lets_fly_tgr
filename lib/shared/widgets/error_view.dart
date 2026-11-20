import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// Error display widget with retry callback.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something Went Wrong',
  });

  final String message;
  final VoidCallback? onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.insetAll24,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 36, color: theme.colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.space20),
              AppButton(
                text: 'Retry',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
