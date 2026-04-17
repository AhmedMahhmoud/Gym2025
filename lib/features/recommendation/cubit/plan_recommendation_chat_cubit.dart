import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackletics/features/recommendation/cubit/plan_recommendation_chat_state.dart';
import 'package:trackletics/features/workouts/cubits/workouts_cubit.dart';
import 'package:trackletics/features/workouts/cubits/workouts_state.dart';

class PlanRecommendationChatCubit extends Cubit<PlanRecommendationChatState> {
  PlanRecommendationChatCubit(this._workoutsCubit)
      : super(const PlanRecommendationChatState());

  final WorkoutsCubit _workoutsCubit;

  static const _kWelcome = 'recommendation.msg_welcome';
  static const _kAskStyle = 'recommendation.msg_ask_style';
  static const _kAskDaysUl = 'recommendation.msg_ask_days_upper_lower';
  static const _kAskDaysPpl = 'recommendation.msg_ask_days_ppl';
  static const _kReady = 'recommendation.msg_ready';
  static const _kGenerating = 'recommendation.msg_generating';

  void openChat() {
    emit(PlanRecommendationChatState(
      messages: const [
        ChatBubbleEntry(isUser: false, messageKey: _kWelcome),
        ChatBubbleEntry(isUser: false, messageKey: _kAskStyle),
      ],
      step: RecommendationChatStep.chooseStyle,
      choices: const [
        RecommendationChoice(
            id: 'fullbody', labelKey: 'recommendation.style_full_body'),
        RecommendationChoice(
            id: 'upper_lower',
            labelKey: 'recommendation.style_upper_lower'),
        RecommendationChoice(
            id: 'ppl', labelKey: 'recommendation.style_ppl'),
        RecommendationChoice(
            id: 'bro', labelKey: 'recommendation.style_bro_split'),
      ],
    ));
  }

  void reset() {
    emit(const PlanRecommendationChatState());
  }

  void requestOpenAiPlansTab() {
    emit(state.copyWith(pendingOpenAiPlansTab: true));
  }

  void clearPendingOpenAiPlansTab() {
    emit(state.copyWith(pendingOpenAiPlansTab: false));
  }

  void selectChoice(String id) {
    final s = state;
    if (s.step == RecommendationChatStep.readyToGenerate && id == 'generate') {
      generatePlan();
      return;
    }
    if (s.step == RecommendationChatStep.success && id == 'view_plans') {
      emit(const PlanRecommendationChatState());
      return;
    }

    final userLabel = _labelForChoice(s.step, id);
    final msgs = List<ChatBubbleEntry>.from(s.messages)
      ..add(ChatBubbleEntry(isUser: true, messageKey: userLabel));

    switch (s.step) {
      case RecommendationChatStep.chooseStyle:
        _afterStyleChoice(msgs, id);
        break;
      case RecommendationChatStep.chooseDaysUpperLower:
        _afterUpperLowerDays(msgs, id);
        break;
      case RecommendationChatStep.chooseDaysPpl:
        _afterPplDays(msgs, id);
        break;
      default:
        break;
    }
  }

  String _labelForChoice(RecommendationChatStep step, String id) {
    switch (step) {
      case RecommendationChatStep.chooseStyle:
        switch (id) {
          case 'fullbody':
            return 'recommendation.pick_full_body';
          case 'upper_lower':
            return 'recommendation.pick_upper_lower';
          case 'ppl':
            return 'recommendation.pick_ppl';
          case 'bro':
            return 'recommendation.pick_bro';
          default:
            return id;
        }
      case RecommendationChatStep.chooseDaysUpperLower:
        return id == 'd2'
            ? 'recommendation.pick_2_days'
            : 'recommendation.pick_4_days';
      case RecommendationChatStep.chooseDaysPpl:
        return id == 'd3'
            ? 'recommendation.pick_3_days'
            : 'recommendation.pick_6_days';
      default:
        return id;
    }
  }

  void _afterStyleChoice(List<ChatBubbleEntry> msgs, String id) {
    switch (id) {
      case 'fullbody':
        msgs.add(const ChatBubbleEntry(
            isUser: false, messageKey: 'recommendation.msg_full_body_note'));
        emit(PlanRecommendationChatState(
          messages: msgs,
          step: RecommendationChatStep.readyToGenerate,
          templateId: 'fullbody-3day',
          choices: const [
            RecommendationChoice(
                id: 'generate', labelKey: 'recommendation.generate_plan'),
          ],
        ));
        break;
      case 'upper_lower':
        msgs.add(const ChatBubbleEntry(
            isUser: false, messageKey: _kAskDaysUl));
        emit(PlanRecommendationChatState(
          messages: msgs,
          step: RecommendationChatStep.chooseDaysUpperLower,
          choices: const [
            RecommendationChoice(
                id: 'd2', labelKey: 'recommendation.days_2_upper_lower'),
            RecommendationChoice(
                id: 'd4', labelKey: 'recommendation.days_4_upper_lower'),
          ],
        ));
        break;
      case 'ppl':
        msgs.add(const ChatBubbleEntry(
            isUser: false, messageKey: _kAskDaysPpl));
        emit(PlanRecommendationChatState(
          messages: msgs,
          step: RecommendationChatStep.chooseDaysPpl,
          choices: const [
            RecommendationChoice(
                id: 'd3', labelKey: 'recommendation.days_3_ppl'),
            RecommendationChoice(
                id: 'd6', labelKey: 'recommendation.days_6_ppl'),
          ],
        ));
        break;
      case 'bro':
        msgs.add(const ChatBubbleEntry(
            isUser: false, messageKey: 'recommendation.msg_bro_note'));
        emit(PlanRecommendationChatState(
          messages: msgs,
          step: RecommendationChatStep.readyToGenerate,
          templateId: 'bro-split-5day',
          choices: const [
            RecommendationChoice(
                id: 'generate', labelKey: 'recommendation.generate_plan'),
          ],
        ));
        break;
      default:
        break;
    }
  }

  void _afterUpperLowerDays(List<ChatBubbleEntry> msgs, String id) {
    final template = id == 'd2' ? 'upper-lower-2day' : 'upper-lower-4day';
    msgs.add(const ChatBubbleEntry(
        isUser: false, messageKey: _kReady));
    emit(PlanRecommendationChatState(
      messages: msgs,
      step: RecommendationChatStep.readyToGenerate,
      templateId: template,
      choices: const [
        RecommendationChoice(
            id: 'generate', labelKey: 'recommendation.generate_plan'),
      ],
    ));
  }

  void _afterPplDays(List<ChatBubbleEntry> msgs, String id) {
    final template = id == 'd3' ? 'ppl-3day' : 'ppl-6day';
    msgs.add(const ChatBubbleEntry(
        isUser: false, messageKey: _kReady));
    emit(PlanRecommendationChatState(
      messages: msgs,
      step: RecommendationChatStep.readyToGenerate,
      templateId: template,
      choices: const [
        RecommendationChoice(
            id: 'generate', labelKey: 'recommendation.generate_plan'),
      ],
    ));
  }

  Future<void> generatePlan() async {
    final templateId = state.templateId;
    if (templateId == null) return;

    final msgs = List<ChatBubbleEntry>.from(state.messages)
      ..add(const ChatBubbleEntry(isUser: false, messageKey: _kGenerating));

    emit(state.copyWith(
      step: RecommendationChatStep.generating,
      messages: msgs,
      choices: const [],
      isGenerating: true,
      clearError: true,
    ));

    await _workoutsCubit.generateRecommendationPlan(templateId);

    final w = _workoutsCubit.state;
    if (w.status == WorkoutsStatus.error) {
      final errMsgs = List<ChatBubbleEntry>.from(msgs)
        ..add(ChatBubbleEntry(
          isUser: false,
          messageKey: 'recommendation.msg_error',
        ));
      emit(PlanRecommendationChatState(
        messages: errMsgs,
        step: RecommendationChatStep.error,
        templateId: templateId,
        errorMessage: w.errorMessage,
        isGenerating: false,
      ));
      return;
    }

    final okMsgs = List<ChatBubbleEntry>.from(msgs)
      ..add(const ChatBubbleEntry(
          isUser: false, messageKey: 'recommendation.msg_success'));

    emit(PlanRecommendationChatState(
      messages: okMsgs,
      step: RecommendationChatStep.success,
      templateId: templateId,
      isGenerating: false,
      choices: const [
        RecommendationChoice(
            id: 'view_plans', labelKey: 'recommendation.view_my_plan'),
      ],
    ));
  }
}
