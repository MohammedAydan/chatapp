import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';

class SaveChatMessageParams {
  final String chatId;
  final List<ChatMessageEntity> chatMessages;

  SaveChatMessageParams({required this.chatId, required this.chatMessages});
}