import 'package:chatapp/features/home/data/models/chat_message_model.dart';

class SendChatMessageParams {
  final String chatId;
  final String fcmToken;
  final ChatMessageModel chatMessage;

  SendChatMessageParams({
    required this.chatId,
    required this.fcmToken,
    required this.chatMessage,
  });
}
