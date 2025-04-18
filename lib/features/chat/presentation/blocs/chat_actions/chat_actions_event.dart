part of 'chat_actions_bloc.dart';

sealed class ChatActionsEvent extends Equatable {
  const ChatActionsEvent();

  @override
  List<Object> get props => [];
}

class SendChatMessageEvent extends ChatActionsEvent {
  final SendChatMessageParams params;

  const SendChatMessageEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class RemoveChatMessageEvent extends ChatActionsEvent {
  final RemoveChatMessageParams params;

  const RemoveChatMessageEvent({required this.params});

  @override
  List<Object> get props => [params];
}