import 'package:chatapp/core/connection/network_info.dart';
import 'package:chatapp/core/errors/errors.dart';
import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/sign_in_params.dart';
import 'package:chatapp/core/params/sign_up_params.dart';
import 'package:chatapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._remoteDatasource, this._networkInfo);

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
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try{
      return Right(await _remoteDatasource.getCurrentUser());
     }on Failure catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    SignInParams params,
  ) async {
    return await _checkNetworkConnection(() async {
      return await _remoteDatasource.signInWithEmailAndPassword(params);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    return await _checkNetworkConnection(() async {
      return await _remoteDatasource.signInWithGoogle();
    });
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    return await _checkNetworkConnection(() async {
      await _remoteDatasource.signOut();
      return unit;
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword(
    SignUpParams params,
  ) async {
    return await _checkNetworkConnection(() async {
      return await _remoteDatasource.signUpWithEmailAndPassword(params);
    });
  }
}
