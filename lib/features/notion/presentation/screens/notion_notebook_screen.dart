import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/notion_controller.dart';

/// Interactive Notion Notebook screen allowing users to connect their workspace,
/// browse authorized lecture notes, and export study summaries directly to Notion.
class NotionNotebookScreen extends ConsumerWidget {
  const NotionNotebookScreen({super.key});

  void _showConnectDialog(BuildContext context, WidgetRef ref) {
    final tokenController = TextEditingController();
    final wsController = TextEditingController(text: 'My Study Workspace');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.08),
                borderRadius: AppSpacing.roundedSm,
              ),
              child: const Icon(Icons.article_outlined, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Connect Notion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Notion Integration Token to securely sync lecture notes with LET\'S FLY TGR:',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: tokenController,
              label: 'Internal Integration Secret',
              hint: 'secret_...',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: wsController,
              label: 'Workspace Label',
              hint: 'e.g. University Study Hub',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final token = tokenController.text.trim();
              final ws = wsController.text.trim();
              if (token.isNotEmpty) {
                ref.read(notionControllerProvider.notifier).connect(token, ws);
                Navigator.of(ctx).pop();
                context.showSnackBar('Notion Workspace connected successfully! 📝');
              }
            },
            child: const Text('Connect Workspace'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notionState = ref.watch(notionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notion Notebook'),
        actions: [
          if (notionState.isConnected)
            IconButton(
              icon: const Icon(Icons.link_off_rounded),
              tooltip: 'Disconnect Notion',
              onPressed: () {
                ref.read(notionControllerProvider.notifier).disconnect();
                context.showSnackBar('Notion disconnected.');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.add_link_rounded),
              tooltip: 'Connect Notion',
              onPressed: () => _showConnectDialog(context, ref),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            AppCard(
              padding: AppSpacing.insetAll20,
              backgroundColor: notionState.isConnected
                  ? AppColors.success.withOpacity(0.08)
                  : theme.colorScheme.primary.withOpacity(0.08),
              borderColor: notionState.isConnected
                  ? AppColors.success.withOpacity(0.3)
                  : theme.colorScheme.primary.withOpacity(0.2),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notionState.isConnected
                          ? AppColors.success.withOpacity(0.15)
                          : theme.colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notionState.isConnected ? Icons.check_circle_rounded : Icons.sync_rounded,
                      color: notionState.isConnected ? AppColors.success : theme.colorScheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notionState.isConnected ? 'Connected to Notion' : 'Sync Notes with Notion',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notionState.isConnected
                              ? 'Authorized pages are synced and ready to link with study sessions.'
                              : 'Link your Notion workspace to read lecture notes and export session logs.',
                          style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (!notionState.isConnected) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showConnectDialog(context, ref),
                      child: const Text('Connect'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Authorized Study Notes', style: AppTypography.titleLarge),
                Text('${notionState.pages.length} Pages', style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            if (notionState.isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notionState.pages.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
                itemBuilder: (context, index) {
                  final page = notionState.pages[index];
                  return AppCard(
                    padding: AppSpacing.insetAll16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(page.icon ?? '📄', style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                page.title,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (page.excerpt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            page.excerpt!,
                            style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Edited: ${page.lastEditedTime.day}/${page.lastEditedTime.month}/${page.lastEditedTime.year}',
                              style: AppTypography.labelSmall.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                              label: const Text('Link to Subject'),
                              onPressed: () {
                                context.showSnackBar('Linked "${page.title}" to active subject!');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
