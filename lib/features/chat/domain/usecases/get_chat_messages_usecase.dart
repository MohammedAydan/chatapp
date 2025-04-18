import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:dartz/dartz.dart';

class GetChatMessagesUsecase {
  final ChatRepository _repository;

  const GetChatMessagesUsecase(this._repository);

  Future<Either<Failure, Stream<List<ChatMessageEntity>>>> call(
    GetChatMessageParams params,
  ) {
    return _repository.getChatMessage(params);
  }
}
