import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/core/utils/format_datetime_utils.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/chat/presentation/widgets/remove_chat_message_bottom_sheet.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.chatId,
    this.fcmToken,
  });

  final ChatMessageEntity message;
  final String chatId;
  final String? fcmToken;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    final String userId = (state is AuthAuthenticated) ? state.user.email : "";
    final bool isMe = message.isMe(userId);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: InkWell(
        onLongPress: () async {
          if (isMe && (message.isDeleted == false)) {
            showRemoveChatMessageBottomSheet(
              contextWrap: context,
              params: RemoveChatMessageParams(
                chatId: chatId,
                messageId: message.id ?? "",
                fcmToken: fcmToken,
              ),
            );
          } else {
            Clipboard.setData(ClipboardData(text: message.message)).then((v) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr.copyMessageSuccess)),
              );
            });
          }
        },
        child: Align(
          alignment:
              // locale?
              (isMe ? Alignment.centerLeft : Alignment.centerRight),
          // : (isMe ? Alignment.centerRight : Alignment.centerLeft)
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment:
                  (isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMe
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMe ? 0 : 16),
                      topRight: Radius.circular(isMe ? 16 : 0),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child:
                      !message.isDeleted
                          ? Text(
                            message.message,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          )
                          : Text(
                            context.tr.deletedMessage,
                            style: TextStyle(
                              color:
                                  isMe
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    if (isMe) ...[
                      message.isReceived || message.isRead
                          ? Icon(
                            Icons.check_circle,
                            size: 17,
                            color:
                                message.isRead
                                    ? Theme.of(context).colorScheme.primary
                                        .withAlpha((0.7 * 255).toInt())
                                    : Theme.of(context).colorScheme.secondary
                                        .withAlpha((0.4 * 255).toInt()),
                          )
                          : Icon(
                            Icons.check_circle_outline,
                            size: 17,
                            color: Theme.of(context).colorScheme.secondary
                                .withAlpha((0.4 * 255).toInt()),
                          ),
                      SizedBox(width: 5),
                    ],
                    Text(
                      formatMessageTimeFromString(
                        message.createdAt,
                        context.tr.locale,
                      ),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
