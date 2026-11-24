import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../controllers/leaderboard_controller.dart';

/// Full interactive study leaderboard screen featuring podium presentation,
/// scope toggles (Global, Friends, Group), and verified time badges.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(leaderboardControllerProvider);
    final notifier = ref.read(leaderboardControllerProvider.notifier);

    final entries = state.entries;
    final topThree = entries.take(3).toList();
    final remainingEntries = entries.skip(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Leaderboard 🏆'),
      ),
      body: Column(
        children: [
          // Period Selector Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: AppSpacing.roundedMd,
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildPeriodTab('Daily', LeaderboardPeriod.daily, state.period, notifier, theme),
                _buildPeriodTab('Weekly', LeaderboardPeriod.weekly, state.period, notifier, theme),
                _buildPeriodTab('Monthly', LeaderboardPeriod.monthly, state.period, notifier, theme),
                _buildPeriodTab('All-Time', LeaderboardPeriod.allTime, state.period, notifier, theme),
              ],
            ),
          ),
          // Scope Toggle (Global vs Friends)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Global'),
                  selected: state.scope == LeaderboardScope.global,
                  onSelected: (_) => notifier.setScope(LeaderboardScope.global),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Friends'),
                  selected: state.scope == LeaderboardScope.friends,
                  onSelected: (_) => notifier.setScope(LeaderboardScope.friends),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Groups'),
                  selected: state.scope == LeaderboardScope.group,
                  onSelected: (_) => notifier.setScope(LeaderboardScope.group),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Main Leaderboard Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: AppSpacing.insetScreen,
                    children: [
                      // Top 3 Podium
                      if (topThree.isNotEmpty) ...[
                        _buildPodium(topThree, theme),
                        const SizedBox(height: AppSpacing.space24),
                      ],
                      // List of ranks 4 and below
                      ...remainingEntries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.space12),
                          child: AppCard(
                            padding: AppSpacing.insetAll16,
                            backgroundColor: entry.isCurrentUser
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : theme.colorScheme.surface,
                            borderColor: entry.isCurrentUser
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '#${entry.rank}',
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AvatarWidget(radius: 18, name: entry.displayName, imageUrl: entry.avatarUrl),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            entry.displayName,
                                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          if (entry.isVerifiedOnly) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '🔥 ${entry.streakDays} Day Streak',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: AppSpacing.roundedSm,
                                  ),
                                  child: Text(
                                    entry.formattedDuration,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(
    String label,
    LeaderboardPeriod period,
    LeaderboardPeriod activePeriod,
    LeaderboardController controller,
    ThemeData theme,
  ) {
    final isSelected = period == activePeriod;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setPeriod(period),
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

  Widget _buildPodium(List<LeaderboardEntryEntity> topThree, ThemeData theme) {
    final rank1 = topThree.first;
    final rank2 = topThree.length > 1 ? topThree[1] : null;
    final rank3 = topThree.length > 2 ? topThree[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (Silver)
        if (rank2 != null)
          _buildPodiumStep(
            entry: rank2,
            rankNum: 2,
            height: 120,
            color: const Color(0xFF94A3B8), // Silver
            badge: '🥈',
            theme: theme,
          ),
        const SizedBox(width: 12),
        // Rank 1 (Gold)
        _buildPodiumStep(
          entry: rank1,
          rankNum: 1,
          height: 150,
          color: const Color(0xFFF59E0B), // Gold
          badge: '👑',
          theme: theme,
        ),
        const SizedBox(width: 12),
        // Rank 3 (Bronze)
        if (rank3 != null)
          _buildPodiumStep(
            entry: rank3,
            rankNum: 3,
            height: 100,
            color: const Color(0xFFD97706), // Bronze
            badge: '🥉',
            theme: theme,
          ),
      ],
    );
  }

  Widget _buildPodiumStep({
    required LeaderboardEntryEntity entry,
    required int rankNum,
    required double height,
    required Color color,
    required String badge,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(badge, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        AvatarWidget(radius: rankNum == 1 ? 26 : 22, name: entry.displayName, imageUrl: entry.avatarUrl),
        const SizedBox(height: 6),
        SizedBox(
          width: 90,
          child: Text(
            entry.displayName,
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          entry.formattedDuration,
          style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: 85,
          height: height * 0.45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$rankNum',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
        ),
      ],
    );
  }
}
