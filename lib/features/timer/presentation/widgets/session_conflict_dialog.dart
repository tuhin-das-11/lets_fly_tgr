import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal dialog presented when an active study session is detected running
/// on another device (e.g. Windows desktop while launching on Android phone).
class SessionConflictDialog extends StatelessWidget {
  const SessionConflictDialog({
    super.key,
    required this.remotePlatform,
    required this.onTakeOver,
    required this.onCancel,
  });

  final String remotePlatform;
  final VoidCallback onTakeOver;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformDisplay = remotePlatform == 'windows' ? 'Windows Desktop' : 'another device ($remotePlatform)';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
      contentPadding: AppSpacing.insetAll24,
      title: Row(
        children: [
          const Icon(Icons.devices_other_rounded, color: AppColors.accent, size: 28),
          const SizedBox(width: AppSpacing.space12),
          const Text('Session In Progress'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are currently studying on $platformDisplay.',
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Would you like to take over this study session seamlessly on this device? Your timer duration and progress will continue without interruption.',
            style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Keep on Other Device'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: onTakeOver,
          child: const Text('Take Over Here'),
        ),
      ],
    );
  }
}
