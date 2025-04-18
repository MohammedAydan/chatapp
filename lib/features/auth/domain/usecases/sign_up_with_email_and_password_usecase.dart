import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/sign_up_params.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

class SignUpWithEmailAndPasswordUsecase {
  final AuthRepository _repository;

  SignUpWithEmailAndPasswordUsecase(this._repository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) {
    return _repository.signUpWithEmailAndPassword(params);
  }
}
