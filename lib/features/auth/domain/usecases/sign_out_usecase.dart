import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

class SignOutUsecase {
  final AuthRepository _repository;

  SignOutUsecase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return _repository.signOut();
  }
}
