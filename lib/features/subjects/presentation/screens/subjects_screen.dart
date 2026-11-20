import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Subject Management screen enabling subject CRUD, target allocations, and color coding.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultSubjects = [
      {'name': 'Computer Science', 'color': AppColors.primary, 'target': '2h 00m', 'icon': Icons.code},
      {'name': 'Mathematics', 'color': AppColors.secondary, 'target': '1h 30m', 'icon': Icons.calculate},
      {'name': 'Physics', 'color': AppColors.accent, 'target': '1h 00m', 'icon': Icons.science},
      {'name': 'Language & Literature', 'color': const Color(0xFFEC4899), 'target': '45m', 'icon': Icons.translate},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects & Targets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Subject dialog available in Phase 2')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: AppSpacing.insetScreen,
        itemCount: defaultSubjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
        itemBuilder: (context, index) {
          final subj = defaultSubjects[index];
          final color = subj['color'] as Color;
          final icon = subj['icon'] as IconData;

          return AppCard(
            padding: AppSpacing.insetAll16,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: AppSpacing.roundedMd,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: AppSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subj['name'] as String,
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        'Target: ${subj["target"]}',
                        style: AppTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
