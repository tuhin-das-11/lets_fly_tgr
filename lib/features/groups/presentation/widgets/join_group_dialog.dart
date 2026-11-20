import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class JoinGroupDialog extends StatefulWidget {
  const JoinGroupDialog({
    super.key,
    required this.onJoin,
  });

  final ValueChanged<String> onJoin;

  @override
  State<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onJoin(_codeController.text.trim().toUpperCase());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: AppSpacing.insetAll24,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Join via Code', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space16),
                Text(
                  'Enter the 8-character invitation code shared by the group owner:',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.space20),
                AppTextField(
                  controller: _codeController,
                  label: 'Invitation Code',
                  hint: 'e.g. GATE2027',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter an invite code';
                    if (v.trim().length < 6) return 'Code must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space24),
                AppButton(
                  text: 'Join Group',
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
