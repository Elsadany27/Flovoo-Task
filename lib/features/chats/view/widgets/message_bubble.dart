import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final colorScheme = Theme.of(context).colorScheme;
    final chatTheme = context.chatTheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? chatTheme.bubbleOutgoing : chatTheme.bubbleIncoming,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isMe ? Colors.white : colorScheme.onSurface,
                      height: 1.35,
                    ),
              ),
            if (message.emoji != null) ...[
              if (message.text.isNotEmpty) const SizedBox(height: 4),
              Text(message.emoji!, style: const TextStyle(fontSize: 26)),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeFormatter.formatChatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.75)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isMe && message.status != null) ...[
                  const SizedBox(width: 4),
                  _MessageStatusIcon(status: message.status!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageStatusIcon extends StatelessWidget {
  const _MessageStatusIcon({required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.75);

    return switch (status) {
      MessageStatus.sending => Icon(Icons.schedule, size: 13, color: color),
      MessageStatus.sent => Icon(Icons.check, size: 13, color: color),
      MessageStatus.delivered => Icon(Icons.done_all, size: 13, color: color),
    };
  }
}
