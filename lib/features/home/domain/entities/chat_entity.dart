import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:chatapp/features/home/domain/entities/participant_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ChatEntity extends Equatable {
  final String id;
  final ChatMessageEntity lastMessage;
  final List<ParticipantEntity> participant;
  final List<String> participantIds;
  final String createdAt;
  final String chatType;
  final bool isDeleted;

  const ChatEntity({
    required this.id,
    required this.lastMessage,
    required this.participant,
    required this.participantIds,
    required this.createdAt,
    required this.chatType,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [
    id,
    lastMessage,
    participant,
    participantIds,
    createdAt,
    chatType,
    isDeleted,
  ];
}
