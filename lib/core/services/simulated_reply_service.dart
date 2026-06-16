import '../../features/chats/data/models/message_model.dart';

class SimulatedReplyService {
  SimulatedReplyService._();

  static MessageModel buildReply({
    required String userText,
    String? userEmoji,
  }) {
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}_reply';
    final timestamp = DateTime.now();

    if (userEmoji != null && userText.isEmpty) {
      return MessageModel(
        id: id,
        text: '',
        emoji: '👋',
        isMe: false,
        timestamp: timestamp,
      );
    }

    final lower = userText.toLowerCase();
    if (lower.contains('hi') ||
        lower.contains('hello') ||
        lower.contains('hey')) {
      return MessageModel(
        id: id,
        text: 'Hello',
        emoji: '👋',
        isMe: false,
        timestamp: timestamp,
      );
    }

    return MessageModel(
      id: id,
      text: 'Thanks for your message!',
      isMe: false,
      timestamp: timestamp,
    );
  }
}
