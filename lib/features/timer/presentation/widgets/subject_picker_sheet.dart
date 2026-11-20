import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../subjects/domain/entities/subject_entity.dart';
import '../../../subjects/presentation/controllers/subjects_controller.dart';
import '../../../subjects/presentation/widgets/subject_icon_picker.dart';

/// Modal bottom sheet to select or switch study subject.
class SubjectPickerSheet extends ConsumerWidget {
  const SubjectPickerSheet({
    super.key,
    required this.selectedSubjectId,
    required this.onSubjectSelected,
  });

  final String selectedSubjectId;
  final ValueChanged<SubjectEntity> onSubjectSelected;

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsControllerProvider);
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.insetAll24,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Subject', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space16),
          subjectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading subjects: $err')),
            data: (subjects) {
              if (subjects.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No subjects created yet. Add one in the Subjects tab.'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final subj = subjects[index];
                  final isSelected = subj.id == selectedSubjectId;
                  final color = _hexToColor(subj.colorHex);
                  final icon = SubjectIconPicker.availableIcons[subj.iconName] ?? Icons.book_rounded;

                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.roundedMd,
                      side: BorderSide(
                        color: isSelected ? color : theme.colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected ? color.withOpacity(0.08) : Colors.transparent,
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(subj.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('${subj.category} • Target ${subj.targetMinutesDaily}m/day'),
                    trailing: isSelected ? Icon(Icons.check_circle_rounded, color: color) : null,
                    onTap: () {
                      onSubjectSelected(subj);
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
