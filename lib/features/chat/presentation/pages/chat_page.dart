import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/get_chat_message_params.dart';
import 'package:chatapp/core/params/set_chat_messages_read_params.dart';
import 'package:chatapp/core/services/custom_notification_service.dart';
import 'package:chatapp/core/services/notification_service.dart';
import 'package:chatapp/core/utils/get_user_avatar.dart';
import 'package:chatapp/di/injection_container.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chatapp/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:chatapp/features/chat/presentation/blocs/chat_actions/chat_actions_bloc.dart';
import 'package:chatapp/features/chat/presentation/widgets/message_bubble.dart';
import 'package:chatapp/features/chat/presentation/widgets/message_bubble_loading.dart';
import 'package:chatapp/features/chat/presentation/widgets/message_input.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/domain/entities/chat_message_entity.dart';
import 'package:chatapp/features/home/domain/entities/participant_entity.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  final ChatEntity chat;

  const ChatPage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final myUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    final participant = _getParticipant(myUser.email);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ChatBloc(
                getChatMessageUsecase: sl(),
                saveChatMessagesLocalUsecase: sl(),
                getChatMessagesFromLocalUsecase: sl(),
                setChatMessagesReadUsecase: sl(),
              )..add(
                GetChatMessagesEvent(
                  params: GetChatMessageParams(ids: chat.participantIds),
                ),
              ),
        ),
        BlocProvider(
          create:
              (context) => ChatActionsBloc(
                sendChatMessageUsecase: sl(),
                removeChatMessageUsecase: sl(),
              ),
        ),
      ],
      child: Scaffold(
        appBar: _buildAppBar(context, participant, myUser),
        body: _buildBody(context, myUser, participant.fcmToken),
      ),
    );
  }

  ParticipantEntity _getParticipant(String myEmail) {
    final isCurrentUser = chat.participant.first.id == myEmail;
    return isCurrentUser ? chat.participant.last : chat.participant.first;
  }

  AppBar _buildAppBar(
    BuildContext context,
    ParticipantEntity participant,
    UserEntity myUser,
  ) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        children: [
          getUserAvatar(participant.id),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              participant.displayName ?? "NO NAME",
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserEntity myUser, String? fcmToken) {
    CustomNotificationService.cancelNotifications(chat.id);

    return Column(
      children: [
        Expanded(child: _buildMessagesList(context, myUser, fcmToken)),
        MessageInput(
          senderId: myUser.email,
          fcmToken: fcmToken ?? "",
          chat: chat,
        ),
      ],
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    UserEntity myUser,
    String? fcmToken,
  ) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return _buildLoadingMessages()
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: Duration(milliseconds: 800),
                delay: Duration(milliseconds: 800),
              );
        }
        if (state is ChatError) {
          return _buildErrorState(context, state.message);
        }
        if (state is ChatLoaded) {
          _markMessagesAsRead(context, myUser);
          return _buildMessages(context, state.chatMessages, fcmToken);
        }
        return _buildErrorState(context, 'Unknown state');
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $message', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          CustomButton(
            onPressed:
                () => context.read<ChatBloc>().add(
                  GetChatMessagesEvent(
                    params: GetChatMessageParams(ids: chat.participantIds),
                  ),
                ),
            child: Text(context.tr.retry),
          ),
        ],
      ),
    );
  }

  void _markMessagesAsRead(BuildContext context, UserEntity myUser) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(
        SetChatMessagesReadEvent(
          params: SetChatMessagesReadParams(
            senderId: myUser.email,
            chatId: chat.id,
          ),
        ),
      );
    });
  }

  Widget _buildMessages(
    BuildContext context,
    List<ChatMessageEntity> messages,
    String? fcmToken,
  ) {
    if (messages.isEmpty) {
      return Center(child: Text(context.tr.noMessagesFound));
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder:
          (context, index) => MessageBubble(
            key: ValueKey(messages[index].id), // Optimize rebuilds
            message: messages[index],
            chatId: chat.id,
            fcmToken: fcmToken,
          ),
    );
  }

  Widget _buildLoadingMessages() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder:
          (context, index) => MessageBubbleLoading(isMe: (index % 3) == 2),
    );
  }
}
