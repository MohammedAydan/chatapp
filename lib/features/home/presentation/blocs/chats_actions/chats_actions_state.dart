part of 'chats_actions_bloc.dart';

sealed class ChatsActionsState extends Equatable {
  const ChatsActionsState();
  
  @override
  List<Object> get props => [];
}

final class ChatsActionsInitial extends ChatsActionsState {}

class ChatsActionsLoading extends ChatsActionsState {}

class SuccessActionsState extends ChatsActionsState {}

class ChatsActionsError extends ChatsActionsState {
  final String message;

  const ChatsActionsError(this.message);

  @override
  List<Object> get props => [message];
}
