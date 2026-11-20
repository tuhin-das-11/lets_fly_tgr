import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../routing/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../controllers/auth_controller.dart';

/// Post-registration profile customizer: unique username, bio, and avatar.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    if (user != null) {
      _displayNameController.text = user.displayName;
      _usernameController.text = user.username;
      _bioController.text = user.bio;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            displayName: _displayNameController.text.trim(),
            username: _usernameController.text.trim(),
            bio: _bioController.text.trim(),
          );
      if (mounted) context.go(RouteNames.dashboard);
    } catch (e) {
      if (mounted) context.showSnackBar(ErrorHandler.getDisplayMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.insetScreen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          AvatarWidget(
                            radius: 48,
                            name: _displayNameController.text.isNotEmpty
                                ? _displayNameController.text
                                : 'Flyer',
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    Text(
                      'Complete Your Profile',
                      style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'Choose how friends and study group peers identify you.',
                      style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    AppTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      hint: 'Alex Walker',
                      validator: Validators.validateDisplayName,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      onFieldSubmitted: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppTextField(
                      controller: _usernameController,
                      label: 'Unique Username',
                      hint: 'alex_walker',
                      validator: Validators.validateUsername,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    AppTextField(
                      controller: _bioController,
                      label: 'Bio / Focus Goal',
                      hint: 'Aspiring Software Architect studying 6 hours a day.',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                    ),
                    const SizedBox(height: AppSpacing.space32),
                    AppButton(
                      text: 'Fly High & Enter App',
                      isLoading: _isLoading,
                      onPressed: _handleSaveProfile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
