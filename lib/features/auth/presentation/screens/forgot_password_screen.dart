import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Password recovery request screen.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendPasswordResetEmail(_emailController.text.trim());
      setState(() => _emailSent = true);
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.insetScreen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _emailSent
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mark_email_read_rounded, size: 40, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: AppSpacing.space24),
                        Text(
                          'Recovery Email Sent',
                          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        Text(
                          'We have dispatched password reset instructions to ${_emailController.text.trim()}. Please inspect your inbox.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.space32),
                        AppButton(
                          text: 'Back to Sign In',
                          onPressed: () => context.pop(),
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Reset Password',
                            style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: AppSpacing.space8),
                          Text(
                            'Enter your registered email address to receive password recovery instructions.',
                            style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.space32),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'student@university.edu',
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.validateEmail,
                            prefixIcon: const Icon(Icons.mail_outline_rounded),
                          ),
                          const SizedBox(height: AppSpacing.space24),
                          AppButton(
                            text: 'Send Reset Link',
                            isLoading: _isLoading,
                            onPressed: _handleReset,
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
