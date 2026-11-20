import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

/// Icon selector for study subject customization.
class SubjectIconPicker extends StatelessWidget {
  const SubjectIconPicker({
    super.key,
    required this.selectedIconName,
    required this.onIconSelected,
    required this.accentColor,
  });

  final String selectedIconName;
  final ValueChanged<String> onIconSelected;
  final Color accentColor;

  static const Map<String, IconData> availableIcons = {
    'book': Icons.menu_book_rounded,
    'code': Icons.code_rounded,
    'calculate': Icons.calculate_rounded,
    'science': Icons.science_rounded,
    'translate': Icons.translate_rounded,
    'brush': Icons.brush_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'history_edu': Icons.history_edu_rounded,
    'psychology': Icons.psychology_rounded,
    'music_note': Icons.music_note_rounded,
    'laptop': Icons.laptop_chromebook_rounded,
    'architecture': Icons.architecture_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.space12,
      runSpacing: AppSpacing.space12,
      children: availableIcons.entries.map((entry) {
        final isSelected = entry.key == selectedIconName;

        return GestureDetector(
          onTap: () => onIconSelected(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.2) : theme.colorScheme.surfaceVariant,
              borderRadius: AppSpacing.roundedMd,
              border: Border.all(
                color: isSelected ? accentColor : Colors.transparent,
                width: 1.8,
              ),
            ),
            child: Icon(
              entry.value,
              color: isSelected ? accentColor : theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        );
      }).toList(),
    );
  }
}
