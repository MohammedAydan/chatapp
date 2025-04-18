import 'package:equatable/equatable.dart';

abstract class ChatMessageEntity extends Equatable {
  final String? id;
  final String senderId;
  final String message;
  final String createdAt;
  final bool isRead;
  final bool isReceived;
  final bool isDeleted;
  final String? replyToMessageId;

  const ChatMessageEntity({
    this.id,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.isReceived = false,
    this.isDeleted = false,
    this.replyToMessageId,
  });

  Map<String, dynamic> toJson();

  bool isMe(String id);

  @override
  List<Object?> get props => [
    id,
    senderId,
    message,
    createdAt,
    isRead,
    isReceived,
    isDeleted,
    replyToMessageId,
  ];
}
