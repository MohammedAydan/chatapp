import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/sign_in_params.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

class SignInWithEmailAndPasswordUsecase {
  final AuthRepository _repository;

  SignInWithEmailAndPasswordUsecase(this._repository);

  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return _repository.signInWithEmailAndPassword(params);
  }
}
