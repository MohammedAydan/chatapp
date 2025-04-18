import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/core/params/save_chat_message_params.dart';
import 'package:chatapp/core/params/send_chat_message_params.dart';
import 'package:chatapp/core/params/set_chat_messages_read_params.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Future<Either<Failure, Stream<List<ChatMessageEntity>>>> getChatMessage(
    GetChatMessageParams params,
  );
  Future<Either<Failure, Stream<List<ChatMessageEntity>>>>
  getChatMessageFromLocalAsStream(GetChatMessageParams params);
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessagesFromLocal(
    GetChatMessageParams params,
  );
  Future<Either<Failure, Unit>> saveChatMessagesFromLocal(
    SaveChatMessageParams params,
  );
  Future<Either<Failure, Unit>> sendChatMessage(SendChatMessageParams params);
  Future<Either<Failure, Unit>> removeChatMessage(
    RemoveChatMessageParams params,
  );
  Future<Either<Failure, Unit>> setChatMessagesRead(
    SetChatMessagesReadParams params,
  );
}
