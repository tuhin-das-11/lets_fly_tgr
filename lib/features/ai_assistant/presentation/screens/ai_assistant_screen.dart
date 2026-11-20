import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../controllers/ai_assistant_controller.dart';

/// Conversational AI Study Assistant screen with quick-prompt chips,
/// markdown formatting, and smart study recommendations.
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(aiAssistantControllerProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(aiAssistantControllerProvider);

    final quickChips = [
      'Explain Concept Simply',
      'Generate 3 MCQs with Answers',
      'Summarize My Study Session',
      'Create 4-Hour Study Plan',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Study Assistant', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                Text('Powered by Gemini / Claude', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Action Suggestion Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: quickChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final chip = quickChips[index];
                return ActionChip(
                  avatar: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.accent),
                  label: Text(chip, style: AppTypography.labelSmall),
                  onPressed: () {
                    ref.read(aiAssistantControllerProvider.notifier).triggerQuickPrompt(chip);
                    _scrollToBottom();
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Chat Log List
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: AppSpacing.insetScreen,
              itemCount: chatState.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                final isUser = msg.sender == MessageSender.user;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
                          bottomLeft: !isUser ? const Radius.circular(2) : const Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        msg.text,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isUser ? Colors.white : theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (chatState.isThinking)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text('Synthesizing study recommendations...', style: AppTypography.bodySmall.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          // Input Box Dock
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.colorScheme.outline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Ask a question, paste notes, or request a quiz...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
