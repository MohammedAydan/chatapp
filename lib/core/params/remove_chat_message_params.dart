class RemoveChatMessageParams {
  final String chatId;
  final String messageId;
  final String? fcmToken;
  final bool isLastMessage;

  RemoveChatMessageParams({
    required this.chatId,
    required this.messageId,
    this.fcmToken,
    this.isLastMessage = false,
  });
}
