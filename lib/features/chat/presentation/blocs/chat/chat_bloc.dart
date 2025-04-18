import 'dart:async';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/core/params/save_chat_message_params.dart';
import 'package:chatapp/core/params/set_chat_messages_read_params.dart';
import 'package:chatapp/core/utils/create_chat_id.dart';
import 'package:chatapp/features/chat/domain/usecases/get_chat_messages_from_local_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/save_chat_messages_local_usecase.dart';
import 'package:chatapp/features/chat/domain/usecases/set_chat_messages_read_usecase.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatMessagesUsecase getChatMessageUsecase;
  final GetChatMessagesFromLocalUsecase getChatMessagesFromLocalUsecase;
  final SaveChatMessagesLocalUsecase saveChatMessagesLocalUsecase;
  final SetChatMessagesReadUsecase setChatMessagesReadUsecase;
  StreamSubscription? _streamSubscription;

  ChatBloc({
    required this.getChatMessageUsecase,
    required this.getChatMessagesFromLocalUsecase,
    required this.saveChatMessagesLocalUsecase,
    required this.setChatMessagesReadUsecase,
  }) : super(ChatInitial()) {
    on<GetChatMessagesEvent>(_getChatMessages);
    on<UpdateChatMessagesEvent>(_updateChatMessages);
    on<SaveChatMessagesEvent>(_saveChatMessages);
    on<SetChatMessagesReadEvent>(_setChatMessagesRead);
  }

  Future<void> _getChatMessages(
    GetChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final cacheResult = await getChatMessagesFromLocalUsecase(event.params);

      cacheResult.fold(
        (failure) {
          emit(ChatError(message: failure.message));
        },
        (data) {
          if (data.isNotEmpty) {
            emit(ChatLoaded(chatMessages: data));
          }
        },
      );

      final result = await getChatMessageUsecase(event.params);
      result.fold(
        (failure) {
          emit(ChatError(message: failure.message));
        },
        (stream) {
          _streamSubscription?.cancel(); // Cancel any existing subscription
          _streamSubscription = stream.listen((chats) {
            add(
              SaveChatMessagesEvent(
                params: SaveChatMessageParams(
                  chatMessages: chats,
                  chatId: createChatId(event.params.ids),
                ),
              ),
            );
            add(UpdateChatMessagesEvent(chatMessages: chats));
          });
        },
      );
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _updateChatMessages(
    UpdateChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoaded(chatMessages: event.chatMessages));
  }

  Future<void> _saveChatMessages(
    SaveChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await saveChatMessagesLocalUsecase(event.params);
    result.fold((failure) => null, (_) => null);
  }

  Future<void> _setChatMessagesRead(
    SetChatMessagesReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    // emit(ChatLoading());
    final result = await setChatMessagesReadUsecase(event.params);

    result.fold((failure) {
      print(failure.message);
      // emit(ChatError(message: failure.message));
    }, (_) {});
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
