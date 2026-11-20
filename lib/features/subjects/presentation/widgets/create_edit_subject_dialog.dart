import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/subject_entity.dart';
import 'subject_color_picker.dart';
import 'subject_icon_picker.dart';

/// Modal dialog/sheet to create or update custom subjects.
class CreateEditSubjectDialog extends StatefulWidget {
  const CreateEditSubjectDialog({
    super.key,
    this.initialSubject,
    required this.onSave,
  });

  final SubjectEntity? initialSubject;
  final void Function({
    required String name,
    required String colorHex,
    required String iconName,
    required String category,
    required int targetMinutesDaily,
  }) onSave;

  @override
  State<CreateEditSubjectDialog> createState() => _CreateEditSubjectDialogState();
}

class _CreateEditSubjectDialogState extends State<CreateEditSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late String _selectedColorHex;
  late String _selectedIconName;
  late int _targetMinutes;

  @override
  void initState() {
    super.initState();
    final init = widget.initialSubject;
    _nameController = TextEditingController(text: init?.name ?? '');
    _categoryController = TextEditingController(text: init?.category ?? 'General');
    _selectedColorHex = init?.colorHex ?? '#4F46E5';
    _selectedIconName = init?.iconName ?? 'book';
    _targetMinutes = init?.targetMinutesDaily ?? 60;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      name: _nameController.text.trim(),
      colorHex: _selectedColorHex,
      iconName: _selectedIconName,
      category: _categoryController.text.trim(),
      targetMinutesDaily: _targetMinutes,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _hexToColor(_selectedColorHex);
    final isEditing = widget.initialSubject != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedXl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                    Text(
                      isEditing ? 'Edit Subject' : 'Create New Subject',
                      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space20),
                AppTextField(
                  controller: _nameController,
                  label: 'Subject Name',
                  hint: 'e.g. Organic Chemistry',
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: AppSpacing.space16),
                AppTextField(
                  controller: _categoryController,
                  label: 'Category',
                  hint: 'e.g. Science, Tech, Exam Prep',
                ),
                const SizedBox(height: AppSpacing.space20),
                Text('Color Code', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.space12),
                SubjectColorPicker(
                  selectedColorHex: _selectedColorHex,
                  onColorSelected: (hex) => setState(() => _selectedColorHex = hex),
                ),
                const SizedBox(height: AppSpacing.space20),
                Text('Icon', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.space12),
                SubjectIconPicker(
                  selectedIconName: _selectedIconName,
                  accentColor: accentColor,
                  onIconSelected: (name) => setState(() => _selectedIconName = name),
                ),
                const SizedBox(height: AppSpacing.space20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Target', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                    Text('${_targetMinutes ~/ 60}h ${_targetMinutes % 60}m / day', style: AppTypography.bodyMedium.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _targetMinutes.toDouble(),
                  min: 15,
                  max: 480, // 8 hours
                  divisions: 31,
                  activeColor: accentColor,
                  label: '${_targetMinutes ~/ 60}h ${_targetMinutes % 60}m',
                  onChanged: (val) => setState(() => _targetMinutes = val.toInt()),
                ),
                const SizedBox(height: AppSpacing.space24),
                AppButton(
                  text: isEditing ? 'Save Changes' : 'Create Subject',
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
