import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/subject_entity.dart';
import '../controllers/subjects_controller.dart';
import '../widgets/create_edit_subject_dialog.dart';
import '../widgets/subject_icon_picker.dart';

/// Full interactive Subject Management screen supporting creation, editing,
/// color-coding, daily target adjustments, and deletion.
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

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

  void _openCreateSubjectDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => CreateEditSubjectDialog(
        onSave: ({
          required String name,
          required String colorHex,
          required String iconName,
          required String category,
          required int targetMinutesDaily,
        }) {
          ref.read(subjectsControllerProvider.notifier).createSubject(
                name: name,
                colorHex: colorHex,
                iconName: iconName,
                category: category,
                targetMinutesDaily: targetMinutesDaily,
              );
          context.showSnackBar('Subject "$name" created successfully!');
        },
      ),
    );
  }

  void _openEditSubjectDialog(BuildContext context, WidgetRef ref, SubjectEntity subject) {
    showDialog(
      context: context,
      builder: (ctx) => CreateEditSubjectDialog(
        initialSubject: subject,
        onSave: ({
          required String name,
          required String colorHex,
          required String iconName,
          required String category,
          required int targetMinutesDaily,
        }) {
          final updated = subject.copyWith(
            name: name,
            colorHex: colorHex,
            iconName: iconName,
            category: category,
            targetMinutesDaily: targetMinutesDaily,
          );
          ref.read(subjectsControllerProvider.notifier).updateSubject(updated);
          context.showSnackBar('Subject updated!');
        },
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, WidgetRef ref, SubjectEntity subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject?'),
        content: Text('Are you sure you want to delete "${subject.name}"? Past recorded study sessions will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(subjectsControllerProvider.notifier).deleteSubject(subject.id);
              Navigator.of(ctx).pop();
              context.showSnackBar('Subject "${subject.name}" deleted.');
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjectsAsync = ref.watch(subjectsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Subject',
            onPressed: () => _openCreateSubjectDialog(context, ref),
          ),
        ],
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(subjectsControllerProvider.notifier).loadSubjects(),
        ),
        data: (subjects) {
          if (subjects.isEmpty) {
            return EmptyState(
              icon: Icons.auto_stories_rounded,
              title: 'No Subjects Yet',
              message: 'Add custom subjects to organize your study sessions, track targets, and monitor your progress.',
              actionLabel: 'Create First Subject',
              onActionPressed: () => _openCreateSubjectDialog(context, ref),
            );
          }

          return ListView.separated(
            padding: AppSpacing.insetScreen,
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
            itemBuilder: (context, index) {
              final subj = subjects[index];
              final color = _hexToColor(subj.colorHex);
              final iconData = SubjectIconPicker.availableIcons[subj.iconName] ?? Icons.menu_book_rounded;
              final targetHours = subj.targetMinutesDaily ~/ 60;
              final targetMins = subj.targetMinutesDaily % 60;

              return AppCard(
                padding: AppSpacing.insetAll16,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: AppSpacing.roundedMd,
                      ),
                      child: Icon(iconData, color: color, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                subj.name,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: AppSpacing.roundedSm,
                                ),
                                child: Text(
                                  subj.category,
                                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${targetHours > 0 ? "${targetHours}h " : ""}${targetMins}m / day',
                            style: AppTypography.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _openEditSubjectDialog(context, ref, subj);
                        } else if (val == 'delete') {
                          _confirmDeleteSubject(context, ref, subj);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSubjectDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Subject'),
      ),
    );
  }
}
