import 'dart:async';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/core/params/remove_chat_params.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/core/params/update_fcm_token_params.dart';
import 'package:chatapp/core/services/custom_notification_service.dart';
import 'package:chatapp/core/services/notification_service.dart';
import 'package:chatapp/features/chat/presentation/pages/chat_page.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/usecases/get_chats_local_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/get_chats_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/save_chats_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/update_fcm_token_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final GetChatsUsecase getChatsUsecase;
  final GetChatsLocalUsecase getChatsLocalUsecase;
  final SaveChatsUsecase saveChatsUsecase;
  final UpdateFcmTokenUsecase updateFcmTokenUsecase;
  StreamSubscription<List<ChatEntity>>? _chatsSubscription;
  StreamSubscription? _notificationSub;
  StreamSubscription? _onRefreshFcmToken;

  ChatsBloc({
    required this.getChatsUsecase,
    required this.getChatsLocalUsecase,
    required this.saveChatsUsecase,
    required this.updateFcmTokenUsecase,
  }) : super(ChatsInitial()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<ChatsUpdatedEvent>(_onChatsUpdated);
    on<ChatsLocalUpdatedEvent>(_onChatsUpdatedLocal);
    on<ChatsStreamErrorEvent>(_onChatsStreamError);
    on<OnNotificationOpen>(_onNotificationOpen);
    on<UpdateFcmTokenEvent>(_updateFcmToken);
    on<OnRefreshFcmTokenEvent>(_onRefreshFcmTokenHandler);
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _notificationSub?.cancel();
    _onRefreshFcmToken?.cancel();
    return super.close();
  }

  Future<void> _onLoadChats(
    LoadChatsEvent event,
    Emitter<ChatsState> emit,
  ) async {
    emit(ChatsLoading());
    final localResult = await getChatsLocalUsecase(event.params);
    localResult.fold((failure) {}, (chats) {
      if (chats.isNotEmpty) {
        emit(ChatsLoaded(chats));
        return;
      }
    });

    await _chatsSubscription?.cancel();

    final result = await getChatsUsecase(event.params);

    result.fold((failure) => emit(ChatsError(failure.message)), (chatStream) {
      _chatsSubscription = chatStream.listen((chats) {
        add(ChatsLocalUpdatedEvent(chats, event.params.userId));
        return add(ChatsUpdatedEvent(chats));
      }, onError: (error) => add(ChatsStreamErrorEvent(error.toString())));
    });
  }

  void _onChatsUpdated(ChatsUpdatedEvent event, Emitter<ChatsState> emit) {
    emit(ChatsLoaded(event.chats));
  }

  void _onChatsUpdatedLocal(
    ChatsLocalUpdatedEvent event,
    Emitter<ChatsState> emit,
  ) async {
    final result = await saveChatsUsecase(event.chats, event.userId);
    // result.fold((failure) => null, (_) => null);
    result.fold((failure) => emit(ChatsError(failure.message)), (_) => null);
  }

  void _onChatsStreamError(
    ChatsStreamErrorEvent event,
    Emitter<ChatsState> emit,
  ) {
    emit(ChatsError(event.error));
  }

  void _onNotificationOpen(
    OnNotificationOpen event,
    Emitter<ChatsState> emit,
  ) async {
    // CustomNotificationService.globalNotificationResponseStream.listen((res) {
    //   try {
    //     if (res.payload == null) return;
    //     if (state is ChatsLoaded) {
    //       final chats = event.chats;

    //       final chat = chats.firstWhere(
    //         (c) => c.id == res.payload,
    //         orElse: () => throw Exception("Chat not found"),
    //       );

    //       if (event.context.mounted) {
    //         Navigator.push(
    //           event.context,
    //           MaterialPageRoute(builder: (context) => ChatPage(chat: chat)),
    //         );
    //       }
    //     }
    //   } catch (e, stack) {
    //     debugPrint("Error navigating from notification: $e");
    //     debugPrintStack(stackTrace: stack);
    //   }
    // });

    // final res = CustomNotificationService.globalNotificationResponse;
    // try {
    //   if (res?.payload == null) return;
    //   if (state is ChatsLoaded) {
    //     final chats = event.chats;

    //     final chat = chats.firstWhere(
    //       (c) => c.id == res?.payload,
    //       orElse: () => throw Exception("Chat not found"),
    //     );

    //     if (event.context.mounted) {
    //       Navigator.push(
    //         event.context,
    //         MaterialPageRoute(builder: (context) => ChatPage(chat: chat)),
    //       );
    //     }
    //   }
    // } catch (e, stack) {
    //   debugPrint("Error navigating from notification: $e");
    //   debugPrintStack(stackTrace: stack);
    // }
  }

  void _updateFcmToken(
    UpdateFcmTokenEvent event,
    Emitter<ChatsState> emit,
  ) async {
    final result = await updateFcmTokenUsecase(event.params);
    result.fold((failure) => emit(ChatsError(failure.message)), (_) => null);
  }

  void _onRefreshFcmTokenHandler(
    OnRefreshFcmTokenEvent event,
    Emitter<ChatsState> emit,
  ) async {
    // final token = await NotificationService.getFcmToken();
    add(UpdateFcmTokenEvent(params: event.params));
  }
}
