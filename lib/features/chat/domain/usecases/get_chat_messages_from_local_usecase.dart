import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:dartz/dartz.dart';

class GetChatMessagesFromLocalUsecase {
  final ChatRepository _repository;

  const GetChatMessagesFromLocalUsecase(this._repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call(GetChatMessageParams params) {
    return _repository.getChatMessagesFromLocal(params);
  }
}
