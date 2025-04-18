import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class SaveChatsUsecase {
  final ChatsRepository _repository;

  const SaveChatsUsecase(this._repository);

  Future<Either<Failure, Unit>> call(
    List<ChatEntity> chats,
    String userId,
  ) async {
    return await _repository.saveChats(chats, userId);
  }
}
