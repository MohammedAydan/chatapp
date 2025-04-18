part of 'chats_bloc.dart';

/// Base class for chat-related events.
abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the list of chats.
class LoadChatsEvent extends ChatsEvent {
  final GetChatsParams params;

  const LoadChatsEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Event to update the chat list from the stream.
class ChatsUpdatedEvent extends ChatsEvent {
  final List<ChatEntity> chats;

  const ChatsUpdatedEvent(this.chats);

  @override
  List<Object?> get props => [chats];
}

/// Event to update the chat list from the local storage.
class ChatsLocalUpdatedEvent extends ChatsEvent {
  final String userId;
  final List<ChatEntity> chats;

  const ChatsLocalUpdatedEvent(this.chats,this.userId);

  @override
  List<Object?> get props => [chats];
}

/// Event to handle stream errors.
class ChatsStreamErrorEvent extends ChatsEvent {
  final String error;

  const ChatsStreamErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class OnNotificationOpen extends ChatsEvent {
  final BuildContext context;
  final List<ChatEntity> chats;

  const OnNotificationOpen({required this.context, required this.chats});

  @override
  List<Object?> get props => [context];
}

class OnRefreshFcmTokenEvent extends ChatsEvent {
  final UpdateFcmTokenParams params;

  const OnRefreshFcmTokenEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

class UpdateFcmTokenEvent extends ChatsEvent {
  final UpdateFcmTokenParams params;

  const UpdateFcmTokenEvent({required this.params});

  @override
  List<Object?> get props => [params];
}
