import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

class SignInWithGoogleUsecase {
  final AuthRepository _repository;

  SignInWithGoogleUsecase(this._repository);

  Future<Either<Failure, UserEntity>> call() {
    return _repository.signInWithGoogle();
  }
}
