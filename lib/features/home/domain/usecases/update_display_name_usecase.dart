import 'package:chatapp/core/errors/failure.dart';
import 'package:chatapp/core/params/update_display_name_params.dart';
import 'package:chatapp/features/home/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateDisplayNameUsecase {
  final ChatsRepository _repository;

  UpdateDisplayNameUsecase(this._repository);

  Future<Either<Failure, Unit>> call(UpdateDisplayNameParams params) {
    return _repository.updateDisplayName(params);
  }
}
