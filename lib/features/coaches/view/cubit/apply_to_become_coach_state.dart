part of 'apply_to_become_coach_cubit.dart';

sealed class ApplyToBecomeCoachState {
  const ApplyToBecomeCoachState();
}

final class ApplyToBecomeCoachInitial extends ApplyToBecomeCoachState {
  const ApplyToBecomeCoachInitial();
}

final class ApplyToBecomeCoachLoading extends ApplyToBecomeCoachState {
  const ApplyToBecomeCoachLoading();
}

final class ApplyToBecomeCoachSuccess extends ApplyToBecomeCoachState {
  const ApplyToBecomeCoachSuccess();
}

final class ApplyToBecomeCoachError extends ApplyToBecomeCoachState {
  const ApplyToBecomeCoachError({required this.message});
  final String message;
}
