import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/home/domain/entities/chat_entity.dart';
import 'package:chatapp/features/home/presentation/widgets/remove_chat_bottom_sheet%20copy.dart';
import 'package:chatapp/features/home/presentation/widgets/update_display_name_chat_bottom_sheet.dart';
import 'package:flutter/material.dart';

void showChatOptionsBottomSheet({
  required BuildContext context,
  required ChatEntity chat,
  required String displayName,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    barrierColor: Colors.grey.withAlpha((0.1 * 255).toInt()),
    showDragHandle: true,
    builder:
        (bottomSheetContext) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr.chatOptions,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(context.tr.editDisplayName),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  showUpdateDisplayNameBottomSheet(
                    contextWrap: context,
                    chat: chat,
                    displayName: displayName,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text(
                  context.tr.removeChat,
                  style: TextStyle(color: Colors.red.shade700),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  showRemoveChatBottomSheet(
                    contextWrap: context,
                    chatId: chat.id,
                  );
                },
              ),
            ],
          ),
        ),
  );
}
