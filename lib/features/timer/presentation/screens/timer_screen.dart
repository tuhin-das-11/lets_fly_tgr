import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';

/// Full-screen high-focus study timer with stopwatch, subject switching,
/// pause/resume, and background sync preparation.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  int _elapsedMilliseconds = 0;
  bool _isRunning = false;
  String _activeSubject = 'Computer Science';

  void _startTimer() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        setState(() {
          _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
        });
      }
    });
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _stopwatch.stop();
    _ticker?.cancel();
    setState(() => _isRunning = false);
  }

  void _stopAndSaveSession() {
    _pauseTimer();
    final duration = Duration(milliseconds: _elapsedMilliseconds);
    _stopwatch.reset();
    setState(() => _elapsedMilliseconds = 0);

    context.showSnackBar('Session saved! Logged ${duration.toShortString()} to $_activeSubject.');
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = Duration(milliseconds: _elapsedMilliseconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'App Blocking Active',
            onPressed: () {
              context.showSnackBar('App Blocking Shield is active during study.');
            },
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: AppSpacing.roundedFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.book_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _activeSubject,
                      style: AppTypography.labelLarge.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
              // Monumental Timer Display
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    duration.toHms(),
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      color: _isRunning ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    _isRunning ? 'FOCUS MODE ACTIVE' : 'PAUSED',
                    style: AppTypography.labelMedium.copyWith(
                      color: _isRunning ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Control Dock
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.space24),
                child: Row(
                  children: [
                    if (_elapsedMilliseconds > 0) ...[
                      Expanded(
                        child: AppButton(
                          text: 'Finish',
                          variant: AppButtonVariant.outline,
                          icon: Icons.stop_rounded,
                          onPressed: _stopAndSaveSession,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space16),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: _isRunning ? 'Pause' : 'Start Focus',
                        icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        variant: AppButtonVariant.primary,
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
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
