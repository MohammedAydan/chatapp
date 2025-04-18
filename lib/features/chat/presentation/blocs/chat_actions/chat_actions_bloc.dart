import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/core/params/send_chat_message_params.dart';
import 'package:chatapp/features/chat/domain/usecases/remove_chat_message_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/send_chat_message_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_actions_event.dart';
part 'chat_actions_state.dart';

class ChatActionsBloc extends Bloc<ChatActionsEvent, ChatActionsState> {
  final SendChatMessageUsecase sendChatMessageUsecase;
  final RemoveChatMessageUsecase removeChatMessageUsecase;

  ChatActionsBloc({
    required this.sendChatMessageUsecase,
    required this.removeChatMessageUsecase,
  }) : super(ChatActionsInitial()) {
    on<SendChatMessageEvent>(_sendChatMessages);
    on<RemoveChatMessageEvent>(_removeChatMessages);
  }

  Future<void> _sendChatMessages(
    SendChatMessageEvent event,
    Emitter<ChatActionsState> emit,
  ) async {
    emit(ChatActionsLoading());
    final result = await sendChatMessageUsecase(event.params);

    result.fold(
      (failure) => emit(ChatActionsError(message: failure.message)),
      (_) => emit(SuccessActionsState()),
    );
  }

  Future<void> _removeChatMessages(
    RemoveChatMessageEvent event,
    Emitter<ChatActionsState> emit,
  ) async {
    emit(ChatActionsLoading());
    final result = await removeChatMessageUsecase(event.params);

    result.fold(
      (failure) => emit(ChatActionsError(message: failure.message)),
      (_) => emit(SuccessActionsState()),
    );
  }
}
