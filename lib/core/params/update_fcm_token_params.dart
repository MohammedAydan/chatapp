import 'package:chatapp/features/home/domain/entities/participant_entity.dart';

class UpdateFcmTokenParams {
  final String chatId;
  final String userId;
  final List<ParticipantEntity> participant;

  const UpdateFcmTokenParams({required this.chatId, required this.userId, required this.participant});
}
