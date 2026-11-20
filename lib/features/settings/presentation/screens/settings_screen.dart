import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
          Text('FOCUS ENFORCEMENT', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('App Blocking Shield'),
            subtitle: const Text('Block distracting apps automatically during active study sessions'),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Keep Screen Awake'),
            subtitle: const Text('Prevent display from sleeping during timer mode'),
            value: true,
            onChanged: (val) {},
          ),
          const Divider(),
          Text('ACCOUNT', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {},
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
