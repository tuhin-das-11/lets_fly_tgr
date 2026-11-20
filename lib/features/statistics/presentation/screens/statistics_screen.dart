import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Analytics dashboard presenting daily, weekly, and subject study metrics.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Analytics'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Toggle
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: AppSpacing.roundedMd,
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppSpacing.roundedSm,
                      ),
                      alignment: Alignment.center,
                      child: Text('Day', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Week', style: AppTypography.labelMedium),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Month', style: AppTypography.labelMedium),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Year', style: AppTypography.labelMedium),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            // High-Level Summary Card
            AppCard(
              padding: AppSpacing.insetAll20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEEKLY TOTAL', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('18h 45m', style: AppTypography.headlineMedium.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('+3h 12m compared to previous week', style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Text('Subject Distribution', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.space12),
            AppCard(
              padding: AppSpacing.insetAll16,
              child: Column(
                children: [
                  _buildSubjectStatRow('Computer Science', '8h 20m', 0.45, AppColors.primary),
                  const SizedBox(height: 12),
                  _buildSubjectStatRow('Mathematics', '5h 15m', 0.28, AppColors.secondary),
                  const SizedBox(height: 12),
                  _buildSubjectStatRow('Physics', '3h 30m', 0.18, AppColors.accent),
                  const SizedBox(height: 12),
                  _buildSubjectStatRow('Literature', '1h 40m', 0.09, const Color(0xFFEC4899)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectStatRow(String name, String time, double ratio, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            Text(time, style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
