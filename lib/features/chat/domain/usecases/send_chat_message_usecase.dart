import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/send_chat_message_params.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SendChatMessageUsecase {
  final ChatRepository _repository;

  SendChatMessageUsecase(this._repository);

  Future<Either<Failure, Unit>> call(SendChatMessageParams params) {
    return _repository.sendChatMessage(params);
  }
}
