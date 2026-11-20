import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../controllers/groups_controller.dart';
import '../widgets/create_group_dialog.dart';
import '../widgets/join_group_dialog.dart';
import 'live_study_room_screen.dart';

/// Groups and social study rooms screen with Tab navigation between "My Groups" and "Discover".
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreateGroup() {
    showDialog(
      context: context,
      builder: (ctx) => CreateGroupDialog(
        onCreate: ({
          required String name,
          required String description,
          required bool isPrivate,
          required int maxMembers,
        }) {
          ref.read(groupsControllerProvider.notifier).createGroup(
                name: name,
                description: description,
                isPrivate: isPrivate,
                maxMembers: maxMembers,
              );
          context.showSnackBar('Study Group "$name" created successfully! 🎉');
        },
      ),
    );
  }

  void _openJoinGroup() {
    showDialog(
      context: context,
      builder: (ctx) => JoinGroupDialog(
        onJoin: (code) {
          ref.read(groupsControllerProvider.notifier).joinWithCode(code);
          context.showSnackBar('Joined study group via code $code! 🚀');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupsState = ref.watch(groupsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Groups & Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined),
            tooltip: 'Join via Invite Code',
            onPressed: _openJoinGroup,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Group',
            onPressed: _openCreateGroup,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: 'My Groups'),
            Tab(text: 'Discover Public Rooms'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: My Groups
          groupsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : groupsState.myGroups.isEmpty
                  ? EmptyState(
                      icon: Icons.groups_rounded,
                      title: 'No Study Groups',
                      message: 'Join peer rooms or create your own study group with a unique invite code.',
                      actionLabel: 'Create Study Group',
                      onActionPressed: _openCreateGroup,
                    )
                  : ListView.separated(
                      padding: AppSpacing.insetScreen,
                      itemCount: groupsState.myGroups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
                      itemBuilder: (context, index) {
                        final group = groupsState.myGroups[index];
                        return AppCard(
                          padding: AppSpacing.insetAll16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      group.name,
                                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                                          '${group.activeStudyingCount} studying',
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
                              const SizedBox(height: 6),
                              Text(
                                group.description,
                                style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${group.memberCount} Members • Code: ${group.inviteCode}',
                                    style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.primary),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.meeting_room_rounded, size: 16),
                                    label: const Text('Enter Room'),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => LiveStudyRoomScreen(group: group),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

          // Tab 2: Discover Public Rooms
          groupsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: AppSpacing.insetScreen,
                  itemCount: groupsState.discoverGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
                  itemBuilder: (context, index) {
                    final group = groupsState.discoverGroups[index];
                    return AppCard(
                      padding: AppSpacing.insetAll16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.12),
                                  borderRadius: AppSpacing.roundedFull,
                                ),
                                child: Text(
                                  '${group.activeStudyingCount} online',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            group.description,
                            style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LiveStudyRoomScreen(group: group),
                                  ),
                                );
                              },
                              child: const Text('View Live Room'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateGroup,
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Create Group'),
      ),
    );
  }
}
