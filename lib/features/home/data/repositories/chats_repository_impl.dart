import 'package:chatapp/core/connection/network_info.dart';
import 'package:chatapp/core/errors/errors.dart';
import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/create_chat_params.dart';
import 'package:chatapp/core/params/get_chats_params.dart';
import 'package:chatapp/core/params/remove_chat_params.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/core/params/update_fcm_token_params.dart';
import 'package:chatapp/features/home/data/datasource/chats_remote_datasource.dart';
import 'package:chatapp/features/home/data/datasource/chats_local_datasource.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class ChatsRepositoryImpl implements ChatsRepository {
  final NetworkInfo _networkInfo;
  final ChatsRemoteDataSource _remoteDataSource;
  final ChatsLocalDataSource _localDataSource;

  ChatsRepositoryImpl(
    this._networkInfo,
    this._remoteDataSource,
    this._localDataSource,
  );

  Future<Either<Failure, T>> _checkNetworkConnection<T>(
    Future<T> Function() action,
  ) async {
    try {
      if ((await _networkInfo.isConnected) == true) {
        return Right(await action());
      } else {
        return Left(OfflineFailure());
      }
    } on Failure catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> createChat(
    CreateChatParams params,
  ) async {
    return await _checkNetworkConnection(
      () async => _remoteDataSource.createChat(params),
    );
  }

  @override
  Future<Either<Failure, Stream<List<ChatEntity>>>> getChats(
    GetChatsParams params,
  ) async {
    if ((await _networkInfo.isConnected) == true) {
      return Right(_remoteDataSource.getChats(params));
    } else {
      try {
        final cachedChats = await _localDataSource.getCachedChats(params);
        return Right(Stream.value(cachedChats));
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> saveChats(
    List<ChatEntity> chats,
    String userId,
  ) async {
    try {
      await _localDataSource.cacheChats(chats, userId);
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatEntity>>> getChatsLocal(
    GetChatsParams params,
  ) async {
    try {
      return Right(await   _localDataSource.getCachedChats(params));
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeChat(RemoveChatParams params) async {
    return await _checkNetworkConnection(() async {
      await _remoteDataSource.removeChat(params.chatId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> updateDisplayName(
    UpdateDisplayNameParams params,
  ) async {
    return await _checkNetworkConnection(() async {
      _remoteDataSource.updateDisplayName(params);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> updateFcmToken(
    UpdateFcmTokenParams params,
  ) async {
    return await _checkNetworkConnection(() async {
      _remoteDataSource.updateFcmToken(params);
      return unit;
    });
  }
}
