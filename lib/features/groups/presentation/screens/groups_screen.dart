import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

/// Groups and social study rooms screen.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final mockGroups = [
      {'name': 'GATE CSE 2027 Aspirants', 'members': 34, 'active': 8, 'category': 'Engineering'},
      {'name': 'Deep Focus 6+ Hours Daily', 'members': 48, 'active': 14, 'category': 'Productivity'},
      {'name': 'Machine Learning Cohort', 'members': 22, 'active': 5, 'category': 'AI/Tech'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups & Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: AppSpacing.insetScreen,
        itemCount: mockGroups.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
        itemBuilder: (context, index) {
          final group = mockGroups[index];
          final activeCount = group['active'] as int;

          return AppCard(
            padding: AppSpacing.insetAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      group['name'] as String,
                      style: AppTypography.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            '$activeCount studying',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${group["members"]} Members • ${group["category"]}',
                  style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Enter Room'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
