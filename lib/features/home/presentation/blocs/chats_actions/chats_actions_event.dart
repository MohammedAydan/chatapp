part of 'chats_actions_bloc.dart';

sealed class ChatsActionsEvent extends Equatable {
  const ChatsActionsEvent();

  @override
  List<Object> get props => [];
}

class CreateChatEvent extends ChatsActionsEvent {
  final CreateChatParams params;

  const CreateChatEvent(this.params);

  @override
  List<Object> get props => [params];
}

class DeleteChatEvent extends ChatsActionsEvent {
  final RemoveChatParams params;

  const DeleteChatEvent(this.params);

  @override
  List<Object> get props => [params];
}

class UpdateDisplayNameEvent extends ChatsActionsEvent {
  final UpdateDisplayNameParams params;

  const UpdateDisplayNameEvent({required this.params});

  @override
  List<Object> get props => [params];
}
