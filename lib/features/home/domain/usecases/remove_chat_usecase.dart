import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/remove_chat_params.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class RemoveChatUsecase {
  final ChatsRepository _repository;

  RemoveChatUsecase(this._repository);

  Future<Either<Failure, Unit>> call(RemoveChatParams params) {
    return _repository.removeChat(params);
  }
}
