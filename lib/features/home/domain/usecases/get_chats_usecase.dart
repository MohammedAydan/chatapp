import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class GetChatsUsecase {
  final ChatsRepository _repository;

  GetChatsUsecase(this._repository);

  Future<Either<Failure, Stream<List<ChatEntity>>>> call(GetChatsParams params) {
    return _repository.getChats(params);
  }
}
