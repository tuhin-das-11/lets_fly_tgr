import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../routing/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../subjects/presentation/controllers/subjects_controller.dart';
import '../../../subjects/presentation/widgets/subject_icon_picker.dart';
import '../../../timer/presentation/controllers/study_timer_controller.dart';

/// Primary Study Dashboard offering one-tap session initiation, streak metrics,
/// daily goal progress, and live peer visibility.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authControllerProvider).value;
    final timerState = ref.watch(studyTimerControllerProvider);
    final subjectsAsync = ref.watch(subjectsControllerProvider);

    final subjects = subjectsAsync.value ?? [];
    final totalTodaySeconds = timerState.todayTotal.inSeconds + (timerState.isRunning ? timerState.elapsed.inSeconds : 0);
    final todayDuration = Duration(seconds: totalTodaySeconds);

    // Default daily target 4 hours (14400s)
    const targetSeconds = 14400;
    final progressRatio = (totalTodaySeconds / targetSeconds).clamp(0.0, 1.0);
    final progressPercent = (progressRatio * 100).toInt();

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
                  timerState.isRunning ? '🔥 Focus session in progress!' : 'Ready to conquer today’s goals?',
                  style: AppTypography.bodySmall.copyWith(
                    color: timerState.isRunning ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                    fontWeight: timerState.isRunning ? FontWeight.bold : FontWeight.normal,
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
              backgroundColor: timerState.isRunning
                  ? AppColors.primary.withOpacity(0.12)
                  : theme.colorScheme.surface,
              borderColor: timerState.isRunning
                  ? AppColors.primary
                  : theme.colorScheme.outline,
              hasShadow: true,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (timerState.isRunning) ...[
                            const CircleAvatar(radius: 4, backgroundColor: AppColors.success),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            timerState.isRunning ? 'CURRENT SESSION' : 'TODAY’S FOCUS TIME',
                            style: AppTypography.labelMedium.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
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
                  const SizedBox(height: AppSpacing.space20),
                  Text(
                    timerState.isRunning ? timerState.elapsed.toHms() : todayDuration.toHms(),
                    style: AppTypography.displayLarge.copyWith(
                      color: timerState.isRunning ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Daily Target: 04h 00m ($progressPercent% completed)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space16),
                  LinearProgressIndicator(
                    value: progressRatio,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressRatio >= 1.0 ? AppColors.accent : theme.colorScheme.primary,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton(
                    text: timerState.isRunning ? 'Return to Active Timer' : 'Start Study Session',
                    icon: timerState.isRunning ? Icons.open_in_new_rounded : Icons.play_arrow_rounded,
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
                  child: const Text('Manage All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space8),
            if (subjects.isEmpty)
              AppCard(
                padding: AppSpacing.insetAll16,
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('No subjects added yet. Tap to create one.', style: AppTypography.bodyMedium),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go(RouteNames.subjects),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemCount: subjects.take(4).length,
                itemBuilder: (context, index) {
                  final subj = subjects[index];
                  final color = _hexToColor(subj.colorHex);
                  final icon = SubjectIconPicker.availableIcons[subj.iconName] ?? Icons.menu_book_rounded;

                  return AppCard(
                    padding: AppSpacing.insetAll16,
                    onTap: () {
                      ref.read(studyTimerControllerProvider.notifier).selectSubject(subj.id);
                      context.go(RouteNames.timer);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color.withOpacity(0.18),
                          child: Icon(icon, size: 18, color: color),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subj.name,
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Target: ${subj.targetMinutesDaily}m/day',
                              style: AppTypography.bodySmall.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
                        Text('Join Live Study Rooms', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          'Connect with peers, compare daily ranks, and study together.',
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
