import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/auth/domain/repositories/auth_respository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUserUsecase {
  final AuthRepository _repository;

  GetCurrentUserUsecase(this._repository);

  Future<Either<Failure, UserEntity>> call() {
    return _repository.getCurrentUser();
  }
}
