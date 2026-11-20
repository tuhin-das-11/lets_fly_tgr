import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/services/ai_assistant_service.dart';
import '../services/ai_assistant_service_impl.dart';

final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AiAssistantServiceImpl(supabase);
});

class AiChatState {
  final List<AiChatMessage> messages;
  final bool isThinking;

  const AiChatState({
    this.messages = const [],
    this.isThinking = false,
  });

  AiChatState copyWith({
    List<AiChatMessage>? messages,
    bool? isThinking,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class AiAssistantController extends StateNotifier<AiChatState> {
  final AiAssistantService _service;
  final _uuid = const Uuid();

  AiAssistantController(this._service)
      : super(
          AiChatState(
            messages: [
              AiChatMessage(
                id: 'welcome',
                text: 'Hello! I am your AI Study Companion for LET\'S FLY TGR.\n\nAsk me to explain difficult concepts simply, summarize your lecture notes, generate flashcards, or create a personalized daily study plan!',
                sender: MessageSender.assistant,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );

  Future<void> sendMessage(String text) async {
    final userMsg = AiChatMessage(
      id: _uuid.v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    try {
      final replyText = await _service.sendChatMessage(
        prompt: text,
        history: state.messages
            .map((m) => {
                  'role': m.sender == MessageSender.user ? 'user' : 'assistant',
                  'content': m.text,
                })
            .toList(),
      );

      final botMsg = AiChatMessage(
        id: _uuid.v4(),
        text: replyText,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isThinking: false,
      );
    } catch (e) {
      final errorMsg = AiChatMessage(
        id: _uuid.v4(),
        text: 'Sorry, I encountered an error: $e. Please try again.',
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isThinking: false,
      );
    }
  }

  void triggerQuickPrompt(String prompt) {
    sendMessage(prompt);
  }
}

final aiAssistantControllerProvider =
    StateNotifierProvider<AiAssistantController, AiChatState>((ref) {
  final service = ref.watch(aiAssistantServiceProvider);
  return AiAssistantController(service);
});
