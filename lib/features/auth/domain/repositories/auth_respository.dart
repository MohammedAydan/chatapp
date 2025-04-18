import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/sign_in_params.dart';
import 'package:chatapp/core/params/sign_up_params.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    SignInParams params,
  );
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword(
    SignUpParams params,
  );
}
