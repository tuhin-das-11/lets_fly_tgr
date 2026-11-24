import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// App preferences: Theme toggle, notification toggles, blocking rules, account info.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: AppSpacing.insetScreen,
        children: [
          Text('APPEARANCE', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable low-luminance AMOLED interface'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme preference saved')),
              );
            },
          ),
          const Divider(),
          Text('SOCIAL & GAMIFICATION', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ListTile(
            leading: Image.asset(AppAssets.icLeaderboard, width: 28, height: 28),
            title: const Text('Global Leaderboard'),
            subtitle: const Text('Compare study rankings across world, friends, and groups'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.leaderboard),
          ),
          ListTile(
            leading: Image.asset(AppAssets.icAchievements, width: 28, height: 28),
            title: const Text('Badges & Milestones'),
            subtitle: const Text('View unlocked study records and streak achievements'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.achievements),
          ),
          ListTile(
            leading: Image.asset(AppAssets.icFriends, width: 28, height: 28),
            title: const Text('Study Friends'),
            subtitle: const Text('Manage friend requests and live peer focus status'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.friends),
          ),
          const Divider(),
          Text('PRODUCTIVITY & INTEGRATIONS', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ListTile(
            leading: Image.asset(AppAssets.icPomodoro, width: 28, height: 28),
            title: const Text('Pomodoro Mode (25/5, 50/10, Deep Work)'),
            subtitle: const Text('Switch from Stopwatch to interval cycles'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.pomodoro),
          ),
          ListTile(
            leading: Image.asset(AppAssets.icNotion, width: 28, height: 28),
            title: const Text('Notion Notebook Integration'),
            subtitle: const Text('Sync authorized lecture pages and export session logs'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.notionNotebook),
          ),
          ListTile(
            leading: Image.asset(AppAssets.icAiAssistant, width: 28, height: 28),
            title: const Text('AI Study Assistant'),
            subtitle: const Text('Summarize notes, explain concepts, generate quizzes'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.aiAssistant),
          ),
          ListTile(
            leading: Image.asset(AppAssets.icAppBlocking, width: 28, height: 28),
            title: const Text('Focus Shield & App Blocking'),
            subtitle: const Text('Configure distracting app blocklist for study sessions'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.appBlocking),
          ),
          const Divider(),
          Text('ACCOUNT', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ListTile(
            leading: Image.asset(AppAssets.icProfile, width: 28, height: 28),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.profileSetup),
          ),
          ListTile(
            leading: Image.asset(AppAssets.icLogout, width: 28, height: 28),
            title: const Text('Sign Out'),
            textColor: theme.colorScheme.error,
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const SizedBox(height: AppSpacing.space32),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    AppAssets.logo,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Study Together. Focus Better. Fly Higher.',
                  style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Text(
                  'Created by Tuhin Das (dastuhin01019@gmail.com)',
                  style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
