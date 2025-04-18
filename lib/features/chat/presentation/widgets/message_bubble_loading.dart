import 'package:flutter/material.dart';

class MessageBubbleLoading extends StatelessWidget {
  const MessageBubbleLoading({super.key, this.isMe = true});

  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Align(
        alignment: isMe ? Alignment.bottomLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 0 : 16),
                    topRight: Radius.circular(isMe ? 16 : 0),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  if (isMe) ...[
                    Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Container(
                    width: 35,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
