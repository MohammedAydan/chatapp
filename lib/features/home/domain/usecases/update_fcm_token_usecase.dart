import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/update_fcm_token_params.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateFcmTokenUsecase {
  final ChatsRepository _repository;

  UpdateFcmTokenUsecase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateFcmTokenParams params) {
    return _repository.updateFcmToken(params);
  }
}
