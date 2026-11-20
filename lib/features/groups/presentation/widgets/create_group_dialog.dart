import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({
    super.key,
    required this.onCreate,
  });

  final void Function({
    required String name,
    required String description,
    required bool isPrivate,
    required int maxMembers,
  }) onCreate;

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPrivate = false;
  int _maxMembers = 50;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onCreate(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      isPrivate: _isPrivate,
      maxMembers: _maxMembers,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
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
                    Text('Create Study Group', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space20),
                AppTextField(
                  controller: _nameController,
                  label: 'Group Name',
                  hint: 'e.g. USMLE 2027 Study Room',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Group name is required' : null,
                ),
                const SizedBox(height: AppSpacing.space16),
                AppTextField(
                  controller: _descController,
                  label: 'Description / Rules',
                  hint: 'Focus guidelines and member expectations...',
                ),
                const SizedBox(height: AppSpacing.space16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Private Group'),
                  subtitle: const Text('Requires 8-character invite code to join'),
                  value: _isPrivate,
                  onChanged: (val) => setState(() => _isPrivate = val),
                ),
                const SizedBox(height: AppSpacing.space24),
                AppButton(
                  text: 'Create Study Group',
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
