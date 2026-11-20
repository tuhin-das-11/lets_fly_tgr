import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../timer/presentation/widgets/timer_ring_widget.dart';
import '../domain/entities/pomodoro_config_entity.dart';
import '../controllers/pomodoro_controller.dart';

/// Full interactive Pomodoro Timer screen with Classic (25/5), Extended (50/10),
/// Deep Work (90/15) presets and automated break alerts.
class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pomoState = ref.watch(pomodoroControllerProvider);
    final notifier = ref.read(pomodoroControllerProvider.notifier);

    final duration = Duration(seconds: pomoState.remainingSeconds);
    final isFocus = pomoState.currentPhase == PomodoroPhase.focus;
    final accentColor = isFocus ? AppColors.primary : AppColors.breakMode;

    String phaseTitle;
    switch (pomoState.currentPhase) {
      case PomodoroPhase.focus:
        phaseTitle = 'DEEP WORK CYCLE';
        break;
      case PomodoroPhase.shortBreak:
        phaseTitle = 'SHORT REST BREAK';
        break;
      case PomodoroPhase.longBreak:
        phaseTitle = 'LONG RECHARGE BREAK';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Focus'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.insetScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Preset Selector Tabs
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: AppSpacing.roundedMd,
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildPresetTab('Classic 25/5', PomodoroPreset.classic, pomoState, notifier, theme),
                    _buildPresetTab('Extended 50/10', PomodoroPreset.extended, pomoState, notifier, theme),
                    _buildPresetTab('Deep 90/15', PomodoroPreset.deepWork, pomoState, notifier, theme),
                  ],
                ),
              ),
              // Monumental Ring Countdown
              TimerRingWidget(
                progress: pomoState.progressRatio,
                accentColor: accentColor,
                size: 290,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      duration.toHms().substring(3), // MM:SS
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: pomoState.isRunning ? accentColor : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        phaseTitle,
                        style: AppTypography.labelSmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cycle Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < (pomoState.completedCycles % 4);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isFilled ? accentColor : theme.colorScheme.surfaceVariant,
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 1.5),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Controls Dock
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space24),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Reset',
                        variant: AppButtonVariant.outline,
                        icon: Icons.replay_rounded,
                        onPressed: notifier.reset,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: pomoState.isRunning ? 'Pause' : 'Start Cycle',
                        icon: pomoState.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        variant: AppButtonVariant.primary,
                        onPressed: pomoState.isRunning ? notifier.pause : notifier.start,
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

  Widget _buildPresetTab(
    String label,
    PomodoroPreset preset,
    PomodoroState state,
    PomodoroController controller,
    ThemeData theme,
  ) {
    final isSelected = state.config.preset == preset;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectPreset(preset),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: AppSpacing.roundedSm,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
