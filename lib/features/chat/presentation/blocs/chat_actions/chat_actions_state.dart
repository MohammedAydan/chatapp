part of 'chat_actions_bloc.dart';

sealed class ChatActionsState extends Equatable {
  const ChatActionsState();
  
  @override
  List<Object> get props => [];
}

final class ChatActionsInitial extends ChatActionsState {}

final class SuccessActionsState extends ChatActionsState {}

final class ChatActionsLoading extends ChatActionsState {}

final class ChatActionsError extends ChatActionsState {
  final String message;

  const ChatActionsError({required this.message});

  @override
  List<Object> get props => [message];
}
