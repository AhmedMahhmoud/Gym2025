import 'package:equatable/equatable.dart';

enum RecommendationChatStep {
  welcome,
  chooseStyle,
  chooseDaysUpperLower,
  chooseDaysPpl,
  readyToGenerate,
  generating,
  success,
  error,
}

class PlanRecommendationChatState extends Equatable {
  final List<ChatBubbleEntry> messages;
  final RecommendationChatStep step;
  final List<RecommendationChoice> choices;
  final String? templateId;
  final bool isGenerating;
  final String? errorMessage;
  /// When true, [PlansScreen] should switch to the AI plans tab (index 1).
  final bool pendingOpenAiPlansTab;

  const PlanRecommendationChatState({
    this.messages = const [],
    this.step = RecommendationChatStep.welcome,
    this.choices = const [],
    this.templateId,
    this.isGenerating = false,
    this.errorMessage,
    this.pendingOpenAiPlansTab = false,
  });

  PlanRecommendationChatState copyWith({
    List<ChatBubbleEntry>? messages,
    RecommendationChatStep? step,
    List<RecommendationChoice>? choices,
    String? templateId,
    bool? isGenerating,
    String? errorMessage,
    bool clearError = false,
    bool clearTemplate = false,
    bool? pendingOpenAiPlansTab,
  }) {
    return PlanRecommendationChatState(
      messages: messages ?? this.messages,
      step: step ?? this.step,
      choices: choices ?? this.choices,
      templateId: clearTemplate ? null : templateId ?? this.templateId,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingOpenAiPlansTab:
          pendingOpenAiPlansTab ?? this.pendingOpenAiPlansTab,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        step,
        choices,
        templateId,
        isGenerating,
        errorMessage,
        pendingOpenAiPlansTab,
      ];
}

class ChatBubbleEntry extends Equatable {
  final bool isUser;
  final String messageKey;

  const ChatBubbleEntry({required this.isUser, required this.messageKey});

  @override
  List<Object?> get props => [isUser, messageKey];
}

class RecommendationChoice extends Equatable {
  final String id;
  final String labelKey;

  const RecommendationChoice({required this.id, required this.labelKey});

  @override
  List<Object?> get props => [id, labelKey];
}
