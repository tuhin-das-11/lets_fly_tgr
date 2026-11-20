import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../controllers/blocking_controller.dart';

/// App Blocking & Focus Shield configuration screen.
class AppBlockingScreen extends ConsumerWidget {
  const AppBlockingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final blockState = ref.watch(blockingControllerProvider);
    final notifier = ref.read(blockingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Shield & App Blocking'),
      ),
      body: ListView(
        padding: AppSpacing.insetScreen,
        children: [
          // Banner card
          AppCard(
            padding: AppSpacing.insetAll20,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
            borderColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: AppSpacing.space12),
                    Text('Zero-Distraction Mode', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus Shield pauses distracting social media and video apps during active study sessions on Android and Windows.',
                  style: AppTypography.bodySmall,
                ),
                if (!blockState.hasUsagePermission) ...[
                  const SizedBox(height: AppSpacing.space16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.security_rounded, size: 18),
                    label: const Text('Grant Usage Access Permission'),
                    onPressed: () {
                      notifier.requestPermission();
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          Text('SHIELD RULES', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Strict Focus Mode'),
            subtitle: const Text('Disables emergency breaks and locks navigation until timer stops'),
            value: blockState.isStrictMode,
            onChanged: notifier.toggleStrictMode,
          ),
          const Divider(),
          Text('DISTRACTING APPS BLOCKLIST', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ...blockState.apps.map((app) {
            return CheckboxListTile(
              title: Text(app.displayName, style: AppTypography.titleSmall),
              subtitle: Text(app.packageName, style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              value: app.isBlocked,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                if (val != null) {
                  notifier.toggleAppBlock(app.packageName, val);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
