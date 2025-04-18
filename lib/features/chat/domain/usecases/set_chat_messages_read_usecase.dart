import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/set_chat_messages_read_params.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SetChatMessagesReadUsecase {
  final ChatRepository _repository;

  SetChatMessagesReadUsecase(this._repository);

  Future<Either<Failure, Unit>> call(SetChatMessagesReadParams params) {
    return _repository.setChatMessagesRead(params);
  }
}
