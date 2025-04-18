// features/home/presentation/widgets/remove_chat_bottom_sheet.dart
import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/core/params/remove_chat_message_params.dart';
import 'package:chatapp/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:chatapp/features/chat/presentation/blocs/chat_actions/chat_actions_bloc.dart';
import 'package:chatapp/global/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showRemoveChatMessageBottomSheet({
  required BuildContext contextWrap,
  required RemoveChatMessageParams params,
}) {
  showModalBottomSheet(
    context: contextWrap,
    backgroundColor: Theme.of(contextWrap).scaffoldBackgroundColor,
    showDragHandle: true,
    builder:
        (bottomSheetContext) => BlocListener<ChatBloc, ChatState>(
          bloc: contextWrap.read(),
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ChatLoaded) {
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
                  contextWrap.tr.removeMessage,
                  style: Theme.of(contextWrap).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  contextWrap.tr.removeMessageConfirm,
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
                          contextWrap.read<ChatActionsBloc>().add(
                            RemoveChatMessageEvent(params: params),
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
