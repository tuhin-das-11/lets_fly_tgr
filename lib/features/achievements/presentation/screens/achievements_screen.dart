import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../controllers/achievements_controller.dart';

/// Milestone achievements and study badges collection screen.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'flight_takeoff':
        return Icons.flight_takeoff_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'timer':
        return Icons.timer_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncAchievements = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Badges 🎖️'),
      ),
      body: asyncAchievements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading achievements: $e')),
        data: (achievements) {
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;

          return ListView(
            padding: AppSpacing.insetScreen,
            children: [
              // Header Summary Card
              AppCard(
                padding: AppSpacing.insetAll20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                borderColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.military_tech_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Badge Collection', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '$unlockedCount of ${achievements.length} Badges Unlocked',
                            style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: achievements.isNotEmpty ? unlockedCount / achievements.length : 0,
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Text('All Milestones', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.space12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final ach = achievements[index];
                  final isUnlocked = ach.isUnlocked;

                  return AppCard(
                    padding: AppSpacing.insetAll16,
                    backgroundColor: isUnlocked
                        ? theme.colorScheme.surface
                        : theme.colorScheme.surfaceVariant.withOpacity(0.35),
                    borderColor: isUnlocked
                        ? AppColors.accent.withOpacity(0.5)
                        : theme.colorScheme.outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? AppColors.accent.withOpacity(0.18)
                                : theme.colorScheme.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _resolveIcon(ach.icon),
                            color: isUnlocked ? AppColors.accent : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                            size: 26,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              ach.title,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ach.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: AppSpacing.roundedSm,
                            ),
                            child: Text(
                              'UNLOCKED ✨',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              LinearProgressIndicator(
                                value: ach.currentProgress,
                                backgroundColor: theme.colorScheme.surfaceVariant,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(ach.currentProgress * 100).toInt()}% Complete',
                                style: AppTypography.labelSmall.copyWith(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
