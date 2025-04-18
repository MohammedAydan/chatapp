// features/home/presentation/widgets/remove_chat_bottom_sheet.dart
import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/remove_chat_params.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/features/home/presentation/blocs/chats_actions/chats_actions_bloc.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showRemoveChatBottomSheet({
  required BuildContext contextWrap,
  required String chatId,
}) {
  showModalBottomSheet(
    context: contextWrap,
    backgroundColor: Theme.of(contextWrap).scaffoldBackgroundColor,
    barrierColor: Colors.grey.withAlpha((0.1 * 255).toInt()),
    showDragHandle: true,
    builder:
        (bottomSheetContext) => BlocListener<ChatsBloc, ChatsState>(
          bloc: contextWrap.read(),
          listener: (context, state) {
            if (state is ChatsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ChatsLoaded) {
              Navigator.of(context).maybePop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  contextWrap.tr.removeChat,
                  style: Theme.of(contextWrap).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  contextWrap.tr.removeChatConfirm,
                  style: Theme.of(contextWrap).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () => Navigator.of(contextWrap).pop(),
                        textButton: true,
                        child: Text(contextWrap.tr.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          contextWrap.read<ChatsActionsBloc>().add(
                            DeleteChatEvent(RemoveChatParams(chatId: chatId)),
                          );
                        },
                        backgroundColor: Colors.red.shade800,
                        child: Text(contextWrap.tr.remove),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
  );
}
