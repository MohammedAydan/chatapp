import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class GetChatsLocalUsecase {
  final ChatsRepository _repository;

  GetChatsLocalUsecase(this._repository);

  Future<Either<Failure, List<ChatEntity>>> call(GetChatsParams  params) {
    return _repository.getChatsLocal(params);
  }
}
