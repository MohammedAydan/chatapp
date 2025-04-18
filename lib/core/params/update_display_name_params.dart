import 'package:chatapp/features/home/domain/entities/participant_entity.dart';

class UpdateDisplayNameParams {
  final String chatId;
  final String userId;
  final String newDisplayName;
  final List<ParticipantEntity> participant;

  const UpdateDisplayNameParams({
    required this.chatId,
    required this.userId,
    required this.newDisplayName,
    required this.participant,
  });
}
