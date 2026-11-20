import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// 30-Day streak calendar matrix visualizing daily study intensity.
class StreakHeatmapWidget extends StatelessWidget {
  const StreakHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Mock 28 days of study intensities (0 = none, 1 = low, 2 = medium, 3 = high)
    final intensities = [
      2, 3, 3, 2, 0, 1, 3,
      3, 3, 2, 3, 3, 1, 2,
      2, 0, 3, 3, 3, 2, 3,
      3, 3, 3, 2, 3, 3, 2,
    ];

    Color getColorForIntensity(int intensity) {
      switch (intensity) {
        case 1:
          return AppColors.primary.withOpacity(0.35);
        case 2:
          return AppColors.primary.withOpacity(0.65);
        case 3:
          return AppColors.primary;
        default:
          return theme.colorScheme.surfaceVariant;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('30-Day Study Consistency', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text('Less', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 4),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 3),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 3),
                Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Text('More', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemCount: intensities.length,
          itemBuilder: (context, index) {
            final intensity = intensities[index];
            return Container(
              decoration: BoxDecoration(
                color: getColorForIntensity(intensity),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ],
    );
  }
}
