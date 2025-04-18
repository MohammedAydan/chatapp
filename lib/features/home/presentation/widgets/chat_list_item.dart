import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/update_fcm_token_params.dart';
import 'package:chatapp/core/utils/format_datetime_utils.dart';
import 'package:chatapp/core/utils/get_user_avatar.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/chat/presentation/pages/chat_page.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/features/home/presentation/widgets/chat_options_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListItem extends StatelessWidget {
  final ChatEntity chat;

  const ChatListItem({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final myUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final isCurrentUser = chat.participant.first.id == myUser.email;
    final String displayName =
        isCurrentUser
            ? (chat.participant.last.displayName ?? "NO NAME")
            : (chat.participant.first.displayName ?? "NO NAME");

    try {
      if (context.mounted) {
        context.read<ChatsBloc>().add(
          OnRefreshFcmTokenEvent(
            params: UpdateFcmTokenParams(
              chatId: chat.id,
              userId: myUser.email,
              participant: chat.participant,
            ),
          ),
        );
      }
    } catch (e) {
      // Silently handle the closed bloc state error
      debugPrint('Failed to refresh FCM token: ${e.toString()}');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: getUserAvatar(
          isCurrentUser ? chat.participant.last.id : chat.participant.first.id,
        ),
        title: Text(
          displayName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            if (chat.lastMessage.isMe(myUser.email)) ...[
              chat.lastMessage.isReceived || chat.lastMessage.isRead
                  ? Icon(
                    Icons.check_circle,
                    size: 17,
                    color:
                        chat.lastMessage.isRead
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha((0.7 * 255).toInt())
                            : Theme.of(context).colorScheme.secondary.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                  )
                  : Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withAlpha((0.4 * 255).toInt()),
                  ),
              SizedBox(width: 5),
            ],
            Expanded(
              child: Text(
                (chat.lastMessage.isDeleted
                    ? "Deleted Message"
                    : chat.lastMessage.message),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          formatMessageTimeFromString(
            chat.lastMessage.createdAt,
            context.tr.locale,
          ),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        tileColor: Colors.transparent,
        onTap: () {
          // Handle chat tap
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatPage(chat: chat)),
          );
        },
        onLongPress: () {
          showChatOptionsBottomSheet(
            context: context,
            chat: chat,
            displayName: displayName,
          );
        },
      ),
    );
  }
}
