import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routing/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Primary Study Dashboard offering one-tap session initiation, streak metrics,
/// daily goal rings, and active peer presence.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AvatarWidget(
              radius: 18,
              name: user?.displayName ?? 'Flyer',
              imageUrl: user?.avatarUrl,
            ),
            const SizedBox(width: AppSpacing.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.displayName ?? "Flyer"} 👋',
                  style: AppTypography.titleMedium,
                ),
                Text(
                  'Ready to conquer today’s goals?',
                  style: AppTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Focus Card with Big Timer and Start Action
            AppCard(
              padding: AppSpacing.insetAll20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
              borderColor: theme.colorScheme.primary.withOpacity(0.2),
              hasShadow: true,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TODAY’S FOCUS TIME',
                        style: AppTypography.labelMedium.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${user?.currentStreakDays ?? 0} Day Streak',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  Text(
                    '00:00:00',
                    style: AppTypography.displayLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Daily Target: 04h 00m (0% completed)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton(
                    text: 'Start Study Session',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.go(RouteNames.timer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            // Quick Subjects Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Subjects',
                  style: AppTypography.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.go(RouteNames.subjects),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: AppSpacing.insetAll16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.code, size: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text('Computer Science', style: AppTypography.titleSmall),
                        Text('0h 00m today', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: AppCard(
                    padding: AppSpacing.insetAll16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.calculate, size: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text('Mathematics', style: AppTypography.titleSmall),
                        Text('0h 00m today', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            // Social Accountability Strip
            Text(
              'Studying Right Now 🟢',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.space12),
            AppCard(
              padding: AppSpacing.insetAll16,
              child: Row(
                children: [
                  const Icon(Icons.group_work_outlined, size: 36, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Join Live Study Rooms', style: AppTypography.titleSmall),
                        Text(
                          'Connect with peers, compare ranks, and fly higher together.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go(RouteNames.groups),
                    child: const Text('Explore'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
