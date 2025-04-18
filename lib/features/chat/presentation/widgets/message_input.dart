import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/send_chat_message_params.dart';
import 'package:chatapp/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:chatapp/features/chat/presentation/blocs/chat_actions/chat_actions_bloc.dart';
import 'package:chatapp/features/home/data/models/chat_message_model.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:chatapp/global/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    super.key,
    required this.senderId,
    required this.chat,
    required this.fcmToken,
  });
  final String senderId;
  final String fcmToken;
  final ChatEntity chat;

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          // top: BorderSide(
          //   color: Theme.of(context).dividerColor.withAlpha((0.4 * 255).toInt()),
          //   width: 1,
          // ),
        ),
      ),
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {
          //     // Add attachment
          //   },
          // ),
          Expanded(
            child: CustomTextFormField(
              controller: messageController,
              labelText: context.tr.typeMessage,
              maxLines: null,
            ),
          ),
          SizedBox(width: 10),
          BlocConsumer<ChatActionsBloc, ChatActionsState>(
            listener: (context, state) {
              if (state is ChatActionsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ChatActionsLoading) {
                return CustomButton(
                  onPressed: null,
                  child: const Icon(Icons.send_rounded),
                );
              }
              return CustomButton(
                child: const Icon(Icons.send_rounded),
                onPressed: () {
                  if (messageController.text.trim().isEmpty) {
                    return;
                  }
                  final chatBloc = context.read<ChatActionsBloc>();
                  chatBloc.add(
                    SendChatMessageEvent(
                      params: SendChatMessageParams(
                        chatId: chat.id,
                        fcmToken: fcmToken,
                        chatMessage: ChatMessageModel(
                          senderId: senderId,
                          message: messageController.text.trim(),
                          createdAt: DateTime.now().toIso8601String(),
                        ),
                      ),
                    ),
                  );
                  messageController.clear();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
