import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveChatMessageUsecase {
  final ChatRepository _repository;

  RemoveChatMessageUsecase(this._repository);

  Future<Either<Failure, Unit>> call(RemoveChatMessageParams params) {
    return _repository.removeChatMessage(params);
  }
}
