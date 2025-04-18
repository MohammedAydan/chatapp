import 'package:chatapp/features/home/data/models/chat_message_model.dart';
import 'package:chatapp/features/home/data/models/participant_model.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.lastMessage,
    required super.participant,
    required super.participantIds,
    required super.createdAt,
    required super.chatType,
    super.isDeleted = false,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"],
      lastMessage: ChatMessageModel.fromJson(json["lastMessage"]),
      participant:
          (json["participant"] as List)
              .map((p) => ParticipantModel.fromJson(p))
              .toList(),
      participantIds:
          (json["participantIds"] is List)
              ? (json["participantIds"] as List)
                  .map((pid) => pid.toString())
                  .toList()
              : [],
      createdAt: json["createdAt"],
      chatType: json["chatType"],
      isDeleted: json["isDeleted"] as bool,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "lastMessage": lastMessage.toJson(),
      "participant": participant.map((p) => p.toJson()),
      "participantIds": participantIds,
      "createdAt": createdAt,
      "chatType": chatType,
      "isDeleted": isDeleted,
    };
  }
}
