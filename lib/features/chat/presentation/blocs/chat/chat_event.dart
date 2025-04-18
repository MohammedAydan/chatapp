part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class GetChatMessagesEvent extends ChatEvent {
  final GetChatMessageParams params;

  const GetChatMessagesEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class UpdateChatMessagesEvent extends ChatEvent {
  final List<ChatMessageEntity> chatMessages;

  const UpdateChatMessagesEvent({required this.chatMessages});

  @override
  List<Object> get props => [chatMessages];
}

// saveChatMessagesLocalUsecase
class SaveChatMessagesEvent extends ChatEvent {
  final SaveChatMessageParams params;

  const SaveChatMessagesEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class SetChatMessagesReadEvent extends ChatEvent {
  final SetChatMessagesReadParams params;

  const SetChatMessagesReadEvent({required this.params});

  @override
  List<Object> get props => [params];
}
