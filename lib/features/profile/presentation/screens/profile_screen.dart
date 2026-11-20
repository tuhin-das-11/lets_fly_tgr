import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// User profile inspection and study achievement showcase.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetScreen,
        child: Column(
          children: [
            Center(
              child: AvatarWidget(
                radius: 44,
                name: user?.displayName ?? 'Flyer',
                imageUrl: user?.avatarUrl,
              ),
            ),
            const SizedBox(height: AppSpacing.space16),
            Text(
              user?.displayName ?? 'Flyer',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '@${user?.username ?? "user"}',
              style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (user?.bio.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                user!.bio,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.space24),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: AppSpacing.insetAll16,
                    child: Column(
                      children: [
                        Text('Current Streak', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        Text('${user?.currentStreakDays ?? 0} Days', style: AppTypography.titleLarge),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: AppCard(
                    padding: AppSpacing.insetAll16,
                    child: Column(
                      children: [
                        Text('Longest Streak', style: AppTypography.labelSmall),
                        const SizedBox(height: 4),
                        Text('${user?.longestStreakDays ?? 0} Days', style: AppTypography.titleLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space32),
            AppButton(
              text: 'Sign Out',
              variant: AppButtonVariant.outline,
              icon: Icons.logout_rounded,
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
