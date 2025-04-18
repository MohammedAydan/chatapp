import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/save_chat_message_params.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SaveChatMessagesLocalUsecase {
  final ChatRepository _repository;

  const SaveChatMessagesLocalUsecase(this._repository);

  Future<Either<Failure, Unit>> call(SaveChatMessageParams params) {
    return _repository.saveChatMessagesFromLocal(params);
  }
}
