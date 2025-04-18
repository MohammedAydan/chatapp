import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:chatapp/features/home/domain/entities/participant_entity.dart';

class CreateChatParams {
  final String senderId;
  final ChatMessageEntity lastMessage;
  final List<ParticipantEntity> participant;
  final List<String> participantIds;
  final String createdAt;
  final String chatType;

  CreateChatParams({
    required this.senderId,
    required this.lastMessage,
    required this.participant,
    required this.participantIds,
    required this.createdAt,
    required this.chatType,
  });
}
