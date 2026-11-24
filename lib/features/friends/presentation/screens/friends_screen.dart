import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../controllers/friends_controller.dart';

/// Social friends list with live peer study status, pending request management,
/// and username invitation dialog.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Friend by Username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter their unique username to connect and track study progress together:'),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller,
              label: 'Username',
              hint: 'e.g. jess_study',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final username = controller.text.trim();
              if (username.isNotEmpty) {
                ref.read(friendsControllerProvider.notifier).sendRequest(username);
                Navigator.of(ctx).pop();
                context.showSnackBar('Friend request sent to @$username! 🤝');
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friendsState = ref.watch(friendsControllerProvider);
    final notifier = ref.read(friendsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Friends 👥'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add Friend',
            onPressed: () => _showAddFriendDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.insetScreen,
        children: [
          // Pending Requests Section
          if (friendsState.pendingRequests.isNotEmpty) ...[
            Text('PENDING REQUESTS', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...friendsState.pendingRequests.map((req) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: AppSpacing.insetAll16,
                  child: Row(
                    children: [
                      AvatarWidget(radius: 20, name: req.displayName),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.displayName, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                            Text('@${req.username}', style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                        onPressed: () => notifier.acceptRequest(req.friendshipId),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel_rounded, color: theme.colorScheme.error),
                        onPressed: () => notifier.declineRequest(req.friendshipId),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          // Active Friends List
          Text('ALL FRIENDS (${friendsState.friends.length})', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...friendsState.friends.map((friend) {
            final isStudying = friend.isStudyingNow;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space12),
              child: AppCard(
                padding: AppSpacing.insetAll16,
                borderColor: isStudying ? AppColors.success.withOpacity(0.4) : theme.colorScheme.outline,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        AvatarWidget(radius: 22, name: friend.displayName, imageUrl: friend.avatarUrl),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(friend.displayName, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Text('🔥 ${friend.streakDays}d', style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (isStudying && friend.currentSubjectName != null)
                            Row(
                              children: [
                                const Text('Studying ', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                                Text(friend.currentSubjectName!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                if (friend.currentDuration != null)
                                  Text(' (${friend.currentDuration!.toShortString()})', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            )
                          else
                            Text('Offline', style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (isStudying)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: const Text('FOCUSING', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFriendDialog(context, ref),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Friend'),
      ),
    );
  }
}
