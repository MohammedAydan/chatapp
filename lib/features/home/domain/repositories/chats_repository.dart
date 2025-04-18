import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/core/params/remove_chat_params.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/core/params/update_fcm_token_params.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ChatsRepository {
  Future<Either<Failure, Stream<List<ChatEntity>>>> getChats(
    GetChatsParams params,
  );
  Future<Either<Failure, List<ChatEntity>>> getChatsLocal(
    GetChatsParams params,
  );
  Future<Either<Failure, Unit>> saveChats(
    List<ChatEntity> chats,
    String userId,
  );
  Future<Either<Failure, ChatEntity>> createChat(CreateChatParams params);
  Future<Either<Failure, Unit>> removeChat(RemoveChatParams params);
  Future<Either<Failure, Unit>> updateFcmToken(UpdateFcmTokenParams params);
  Future<Either<Failure, Unit>> updateDisplayName(
    UpdateDisplayNameParams params,
  );
}
