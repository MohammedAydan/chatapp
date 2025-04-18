import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class CreateChatUsecase {
  final ChatsRepository _repository;

  CreateChatUsecase(this._repository);

  Future<Either<Failure, ChatEntity>> call(CreateChatParams params) {
    return _repository.createChat(params);
  }
}
