import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../widgets/streak_heatmap_widget.dart';
import '../widgets/study_bar_chart.dart';
import '../widgets/subject_pie_chart.dart';

/// Comprehensive Analytics Dashboard displaying study trends, subject distributions,
/// peak hours, and unlockable achievement milestones.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 1; // 0=Day, 1=Week, 2=Month, 3=Year

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pieItems = const [
      SubjectPieItem(name: 'Computer Science', hours: 14.5, color: AppColors.primary),
      SubjectPieItem(name: 'Mathematics', hours: 9.0, color: AppColors.secondary),
      SubjectPieItem(name: 'Physics', hours: 6.2, color: AppColors.accent),
      SubjectPieItem(name: 'Literature', hours: 3.5, color: Color(0xFFEC4899)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Records'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period Segmented Selector
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: AppSpacing.roundedMd,
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ['Day', 'Week', 'Month', 'Year'].asMap().entries.map((entry) {
                  final isSelected = _selectedPeriod == entry.key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = entry.key),
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
                          entry.value,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.space20),
            // High-Level Total Card
            AppCard(
              padding: AppSpacing.insetAll20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.06),
              borderColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WEEKLY FOCUS TIME', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('33h 12m', style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 16),
                          const SizedBox(width: 4),
                          Text('+4h 30m vs last week', style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            // Weekly Bar Chart
            AppCard(
              padding: AppSpacing.insetAll16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Study Hours', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Average: 4h 44m / day', style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.space20),
                  const StudyBarChart(
                    dailyHours: [4.5, 5.8, 6.2, 3.5, 5.0, 7.2, 4.0],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            // Subject Distribution Pie Chart
            AppCard(
              padding: AppSpacing.insetAll16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject Distribution', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.space16),
                  Row(
                    children: [
                      Expanded(
                        child: SubjectPieChart(items: pieItems),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pieItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 5, backgroundColor: item.color),
                                const SizedBox(width: 8),
                                Text(item.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                Text('${item.hours}h', style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            // Streak Consistency Heatmap
            AppCard(
              padding: AppSpacing.insetAll16,
              child: const StreakHeatmapWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
