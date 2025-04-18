// features/home/presentation/widgets/chat_list.dart
import 'package:chatapp/core/extensions/localization_extension.dart';
import 'package:chatapp/features/home/presentation/blocs/chats/chats_bloc.dart';
import 'package:chatapp/features/home/presentation/widgets/chat_list_item.dart';
import 'package:chatapp/features/home/presentation/widgets/chat_list_item_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatList extends StatelessWidget {
  final ChatsState state;

  const ChatList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is ChatsLoading) {
      return SliverToBoxAdapter(
        child: Column(
          children: List.generate(
            10,
            (index) => const ChatListItemLoading()
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: Duration(milliseconds: 800),
                  delay: Duration(milliseconds: 800),
                ),
          ),
        ),
      );
    }

    if (state is ChatsError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            children: [
              Text(
                'Error: ${(state as ChatsError).message}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ChatsLoaded) {
      final chats = (state as ChatsLoaded).chats;
      if (chats.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(child: Text(context.tr.chatsEmpty)),
        );
      }
      if (context.mounted && !context.read<ChatsBloc>().isClosed) {
        context.read<ChatsBloc>().add(
          OnNotificationOpen(context: context, chats: chats),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ChatListItem(chat: chats[index]),
          childCount: chats.length,
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox());
  }
}
