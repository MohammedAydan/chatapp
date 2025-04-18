import 'package:chatapp/core/connection/network_info.dart';
import 'package:chatapp/core/errors/errors.dart';
import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/core/params/save_chat_message_params.dart';
import 'package:chatapp/core/params/send_chat_message_params.dart';
import 'package:chatapp/core/params/set_chat_messages_read_params.dart';
import 'package:chatapp/features/chat/data/datasource/chat_local_datasource.dart';
import 'package:chatapp/features/chat/data/datasource/chat_remote_datasource.dart';
import 'package:chatapp/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:dartz/dartz.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _chatRemoteDatasource;
  final ChatLocalDatasource _chatLocalDatasource;
  final NetworkInfo _networkInfo;

  ChatRepositoryImpl(
    this._chatRemoteDatasource,
    this._chatLocalDatasource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, Stream<List<ChatMessageEntity>>>> getChatMessage(
    GetChatMessageParams params,
  ) async {
    if ((await _networkInfo.isConnected) == true) {
      try {
        return Right(_chatRemoteDatasource.getChatMessages(params));
      } on Failure catch (e) {
        return Left(Failure(e.message));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      try {
        return Right(_chatLocalDatasource.getChatMessagesAsStream(params));
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Stream<List<ChatMessageEntity>>>>
  getChatMessageFromLocalAsStream(GetChatMessageParams params) async {
    try {
      return Right(_chatLocalDatasource.getChatMessagesAsStream(params));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatMessagesFromLocal(
    GetChatMessageParams params,
  ) async {
    try {
      return Right(_chatLocalDatasource.getChatMessages(params));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveChatMessagesFromLocal(
    SaveChatMessageParams params,
  ) async {
    try {
      await _chatLocalDatasource.saveMessages(
        params.chatId,
        params.chatMessages,
      );
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeChatMessage(
    RemoveChatMessageParams params,
  ) async {
    if ((await _networkInfo.isConnected) == true) {
      try {
        await _chatRemoteDatasource.removeChatMessage(params);
        return Right(unit);
      } on Failure catch (e) {
        return Left(Failure(e.message));
      } on Exception catch (e) {
        return Left(handleException(e));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendChatMessage(
    SendChatMessageParams params,
  ) async {
    if ((await _networkInfo.isConnected) == true) {
      try {
        await _chatRemoteDatasource.sendChatMessages(params);
        return Right(unit);
      } on Failure catch (e) {
        return Left(Failure(e.message));
      } on Exception catch (e) {
        return Left(handleException(e));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setChatMessagesRead(
    SetChatMessagesReadParams params,
  ) async {
    if ((await _networkInfo.isConnected) == true) {
      try {
        await _chatRemoteDatasource.setChatMessagesRead(params);
        return Right(unit);
      } on Failure catch (e) {
        return Left(Failure(e.message));
      } on Exception catch (e) {
        return Left(handleException(e));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
