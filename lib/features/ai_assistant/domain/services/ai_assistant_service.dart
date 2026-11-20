/// Abstract provider-independent AI service interface (Gemini / Anthropic / OpenAI).
abstract class AiAssistantService {
  /// Generate a concise summary of raw lecture notes or study materials.
  Future<String> summarizeNotes(String notes);

  /// Explain a difficult academic concept simply using analogies.
  Future<String> explainConceptSimply(String concept);

  /// Generate practice Multiple Choice Questions with explanations.
  Future<String> generateMcqs({required String topic, int count = 3});

  /// Create a personalized structured daily study plan.
  Future<String> generateStudyPlan({
    required List<String> subjects,
    required int availableHours,
  });

  /// Interactive conversational Q&A.
  Future<String> sendChatMessage({
    required String prompt,
    required List<Map<String, String>> history,
  });
}
