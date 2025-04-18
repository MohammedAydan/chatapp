import 'package:flutter/material.dart';

class ChatListItemLoading extends StatelessWidget {
  const ChatListItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    Color pColor = Theme.of(context).colorScheme.secondary.withAlpha((0.3 * 255).toInt());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: pColor,
        ),
        title: Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: pColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        subtitle: Container(
          height: 12,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: pColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        tileColor: Colors.transparent,
      ),
    );
  }
}
