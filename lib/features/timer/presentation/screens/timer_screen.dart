import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../subjects/presentation/controllers/subjects_controller.dart';
import '../../../subjects/presentation/widgets/subject_icon_picker.dart';
import '../controllers/study_timer_controller.dart';
import '../widgets/session_conflict_dialog.dart';
import '../widgets/subject_picker_sheet.dart';
import '../widgets/timer_ring_widget.dart';

/// Full interactive study timer screen connected to the server-authoritative
/// cross-device sync engine.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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

  void _openSubjectPicker() {
    final timerState = ref.read(studyTimerControllerProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SubjectPickerSheet(
        selectedSubjectId: timerState.currentSubjectId,
        onSubjectSelected: (subj) {
          ref.read(studyTimerControllerProvider.notifier).selectSubject(subj.id);
        },
      ),
    );
  }

  void _promptStopSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finish Study Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Great job on your focus! Add quick notes or key takeaways before saving:'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Completed Chapter 4 practice exercises.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue Studying'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(studyTimerControllerProvider.notifier).stopAndCommitSession(
                    notes: _notesController.text.trim(),
                  );
              _notesController.clear();
              context.showSnackBar('Study session successfully logged to your profile! 🚀');
            },
            child: const Text('Save & Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerState = ref.watch(studyTimerControllerProvider);
    final subjectsAsync = ref.watch(subjectsControllerProvider);

    // Conflict Takeover Trigger
    if (timerState.isCrossDeviceConflict) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => SessionConflictDialog(
            remotePlatform: timerState.conflictDevicePlatform ?? 'another device',
            onTakeOver: () {
              Navigator.of(ctx).pop();
              ref.read(studyTimerControllerProvider.notifier).takeOverSession();
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
        );
      });
    }

    // Resolve active subject
    final subjects = subjectsAsync.value ?? [];
    final activeSubject = subjects.firstWhere(
      (s) => s.id == timerState.currentSubjectId,
      orElse: () => subjects.isNotEmpty
          ? subjects.first
          : null as dynamic,
    );

    final subjectName = activeSubject?.name ?? 'Select Subject';
    final subjectColor = activeSubject != null ? _hexToColor(activeSubject.colorHex) : AppColors.primary;
    final subjectIcon = activeSubject != null
        ? (SubjectIconPicker.availableIcons[activeSubject.iconName] ?? Icons.menu_book_rounded)
        : Icons.menu_book_rounded;

    final targetMinutes = activeSubject?.targetMinutesDaily ?? 60;
    final progressRatio = (timerState.elapsed.inMinutes / targetMinutes).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'App Blocking Active',
            onPressed: () => context.showSnackBar('Focus Shield is actively protecting your study session.'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.insetScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Subject Pill Selector
              GestureDetector(
                onTap: timerState.isRunning ? null : _openSubjectPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.12),
                    borderRadius: AppSpacing.roundedFull,
                    border: Border.all(color: subjectColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(subjectIcon, size: 18, color: subjectColor),
                      const SizedBox(width: 8),
                      Text(
                        subjectName,
                        style: AppTypography.labelLarge.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!timerState.isRunning) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
              // Monumental Timer Ring Display
              TimerRingWidget(
                progress: progressRatio,
                accentColor: subjectColor,
                size: 290,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timerState.elapsed.toHms(),
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        color: timerState.isRunning ? subjectColor : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: timerState.isRunning
                            ? AppColors.success.withOpacity(0.12)
                            : (timerState.isPaused ? AppColors.warning.withOpacity(0.12) : theme.colorScheme.surfaceVariant),
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        timerState.isRunning ? 'FOCUS MODE' : (timerState.isPaused ? 'PAUSED' : 'READY'),
                        style: AppTypography.labelSmall.copyWith(
                          color: timerState.isRunning
                              ? AppColors.success
                              : (timerState.isPaused ? AppColors.warning : theme.colorScheme.onSurfaceVariant),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target: ${targetMinutes ~/ 60}h ${targetMinutes % 60}m',
                      style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Control Dock
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space24),
                child: Row(
                  children: [
                    if (timerState.elapsed.inSeconds > 0) ...[
                      Expanded(
                        child: AppButton(
                          text: 'Finish',
                          variant: AppButtonVariant.outline,
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: _promptStopSession,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space16),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: timerState.isRunning ? 'Pause' : 'Start Focus',
                        icon: timerState.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        variant: AppButtonVariant.primary,
                        isLoading: timerState.isLoading,
                        onPressed: () {
                          final notifier = ref.read(studyTimerControllerProvider.notifier);
                          if (timerState.isRunning) {
                            notifier.pauseTimer();
                          } else if (timerState.isPaused) {
                            notifier.resumeTimer();
                          } else {
                            notifier.startTimer(subjectId: activeSubject?.id);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
