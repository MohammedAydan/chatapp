import 'package:chatapp/core/helpers/encryption_helper.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    super.id,
    required super.senderId,
    required super.message,
    required super.createdAt,
    super.isRead = false,
    super.isReceived = false,
    super.isDeleted = false,
    super.replyToMessageId,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    String key = dotenv.maybeGet("ENCRYPTION_KEY") ?? "";
    String decryptedMessage = EncryptionHelper.decryptText(
      json['message'],
      key,
    );
    return ChatMessageModel(
      id: json['id'] ?? "",
      senderId: json['senderId'] ?? "",
      message: decryptedMessage,
      createdAt: json['createdAt'] as String,
      isRead: json['isRead'] as bool,
      isReceived: json["isReceived"] ? json["isReceived"] : false,
      isDeleted: json['isDeleted'] as bool,
      replyToMessageId: json['replyToMessageId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    String key = dotenv.maybeGet("ENCRYPTION_KEY") ?? "";
    String encryptedMessage = EncryptionHelper.encryptText(message, key);
    return {
      // 'id': id,
      'senderId': senderId,
      'message': encryptedMessage,
      'createdAt': createdAt,
      'isRead': isRead,
      'isReceived': isReceived,
      'isDeleted': isDeleted,
      'replyToMessageId': replyToMessageId,
    };
  }

  @override
  bool isMe(String id) {
    return id == senderId;
  }
}
