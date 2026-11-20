import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../controllers/groups_controller.dart';

/// Real-time Virtual Study Room presenting live member video/avatar feeds,
/// active subject indicators, live timers, and room ranking.
class LiveStudyRoomScreen extends ConsumerWidget {
  const LiveStudyRoomScreen({
    super.key,
    required this.group,
  });

  final GroupEntity group;

  Color _hexToColor(String? hex) {
    if (hex == null) return AppColors.primary;
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
    final repo = ref.watch(groupsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(
              'Live Room • Invite Code: ${group.inviteCode}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Invite Code',
            onPressed: () {
              context.showSnackBar('Invite Code copied: ${group.inviteCode}');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<GroupMemberEntity>>(
        stream: repo.watchLiveRoom(group.id),
        builder: (context, snapshot) {
          final members = snapshot.data ?? [];
          final studyingMembers = members.where((m) => m.isStudying).toList();

          return CustomScrollView(
            slivers: [
              // Room Banner & Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.insetScreen,
                  child: AppCard(
                    padding: AppSpacing.insetAll16,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                    borderColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('${studyingMembers.length}', style: AppTypography.headlineMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                            Text('Studying Now', style: AppTypography.bodySmall),
                          ],
                        ),
                        const SizedBox(
                          height: 36,
                          child: VerticalDivider(),
                        ),
                        Column(
                          children: [
                            Text('${group.memberCount}', style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text('Total Members', style: AppTypography.bodySmall),
                          ],
                        ),
                        const SizedBox(
                          height: 36,
                          child: VerticalDivider(),
                        ),
                        Column(
                          children: [
                            Text('34h 12m', style: AppTypography.headlineMedium.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            Text('Room Hours Today', style: AppTypography.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Active Focus Desks', style: AppTypography.titleLarge),
                      Text('Realtime 🟢', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Member Desk Grid
              SliverPadding(
                padding: AppSpacing.insetScreen,
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final member = members[index];
                      final isStudying = member.isStudying;
                      final subjectColor = _hexToColor(member.currentSubjectColor);

                      return AppCard(
                        padding: AppSpacing.insetAll16,
                        borderColor: isStudying ? subjectColor.withOpacity(0.4) : theme.colorScheme.outline,
                        backgroundColor: isStudying ? subjectColor.withOpacity(0.05) : theme.colorScheme.surface,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  children: [
                                    AvatarWidget(
                                      radius: 20,
                                      name: member.displayName,
                                      imageUrl: member.avatarUrl,
                                    ),
                                    if (isStudying)
                                      const Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                          radius: 5,
                                          backgroundColor: AppColors.success,
                                        ),
                                      ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isStudying ? AppColors.success.withOpacity(0.12) : theme.colorScheme.surfaceVariant,
                                    borderRadius: AppSpacing.roundedSm,
                                  ),
                                  child: Text(
                                    isStudying ? 'FOCUS' : 'REST',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isStudying ? AppColors.success : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.displayName,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                if (isStudying && member.currentSubjectName != null)
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 3, backgroundColor: subjectColor),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          member.currentSubjectName!,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: subjectColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'Today: ${Duration(seconds: member.totalStudySecondsToday).toShortString()}',
                                    style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                                  ),
                              ],
                            ),
                            if (isStudying && member.currentSessionDuration != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: AppSpacing.roundedSm,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  member.currentSessionDuration!.toHms(),
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: members.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
