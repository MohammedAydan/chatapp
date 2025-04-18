import 'package:bloc/bloc.dart';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/core/params/remove_chat_params.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/features/home/domain/usecases/create_chat_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/remove_chat_usecase.dart';
import 'package:chatapp/features/home/domain/usecases/update_display_name_usecase.dart';
import 'package:equatable/equatable.dart';

part 'chats_actions_event.dart';
part 'chats_actions_state.dart';

class ChatsActionsBloc extends Bloc<ChatsActionsEvent, ChatsActionsState> {
  final CreateChatUsecase createChatUsecase;
  final UpdateDisplayNameUsecase updateDisplayNameUsecase;
  final RemoveChatUsecase removeChatUsecase;

  ChatsActionsBloc({
    required this.createChatUsecase,
    required this.updateDisplayNameUsecase,
    required this.removeChatUsecase,
  }) : super(ChatsActionsInitial()) {
    on<CreateChatEvent>(_onCreateChat);
    on<UpdateDisplayNameEvent>(_updateDisplayName);
    on<DeleteChatEvent>(_onDeleteChat);
  }

  Future<void> _onCreateChat(
    CreateChatEvent event,
    Emitter<ChatsActionsState> emit,
  ) async {
    emit(ChatsActionsLoading());
    final result = await createChatUsecase(event.params);
    result.fold(
      (failure) => emit(ChatsActionsError(failure.message)),
      (_) => emit(SuccessActionsState()),
    );
  }

  Future<void> _updateDisplayName(
    UpdateDisplayNameEvent event,
    Emitter<ChatsActionsState> emit,
  ) async {
    emit(ChatsActionsLoading());
    final result = await updateDisplayNameUsecase(event.params);
    result.fold(
      (failure) => emit(ChatsActionsError(failure.message)),
      (_) => emit(SuccessActionsState()),
    );
  }

  Future<void> _onDeleteChat(
    DeleteChatEvent event,
    Emitter<ChatsActionsState> emit,
  ) async {
    emit(ChatsActionsLoading());
    final result = await removeChatUsecase(event.params);
    result.fold(
      (failure) => emit(ChatsActionsError(failure.message)),
      (_) => emit(SuccessActionsState()),
    );
  }
}
