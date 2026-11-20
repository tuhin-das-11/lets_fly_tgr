import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          Text('PRODUCTIVITY TOOLS', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Pomodoro Mode (25/5, 50/10, Deep Work)'),
            subtitle: const Text('Switch from Stopwatch to interval cycles'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.pomodoro),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('AI Study Assistant'),
            subtitle: const Text('Summarize notes, explain concepts, generate quizzes'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.aiAssistant),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Focus Shield & App Blocking'),
            subtitle: const Text('Configure distracting app blocklist for study sessions'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.appBlocking),
          ),
          const Divider(),
          Text('ACCOUNT', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => context.push(RouteNames.profileSetup),
          ),
          ListTile(
            title: const Text('Sign Out'),
            textColor: theme.colorScheme.error,
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const SizedBox(height: AppSpacing.space32),
          Center(
            child: Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
