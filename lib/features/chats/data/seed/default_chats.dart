import '../models/chat_model.dart';
import '../models/message_model.dart';

class DefaultChats {
  DefaultChats._();

  static List<ChatModel> create() {
    final now = DateTime.now();

    return [
      ChatModel(
        id: 'chat_sarah',
        title: 'Sarah Johnson',
        unreadCount: 2,
        updatedAt: now.subtract(const Duration(minutes: 12)),
        messages: [
          MessageModel(
            id: 'msg_s1',
            text: 'Hey! Are we still meeting today?',
            isMe: false,
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          MessageModel(
            id: 'msg_s2',
            text: 'Yes, at 5 PM works for me.',
            isMe: true,
            timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
            status: MessageStatus.delivered,
          ),
          MessageModel(
            id: 'msg_s3',
            text: 'Perfect! See you tomorrow!',
            emoji: '😊',
            isMe: false,
            timestamp: now.subtract(const Duration(minutes: 12)),
          ),
        ],
      ),
      ChatModel(
        id: 'chat_james',
        title: 'James Miller',
        unreadCount: 1,
        updatedAt: now.subtract(const Duration(hours: 2)),
        messages: [
          MessageModel(
            id: 'msg_j1',
            text: 'Hi, did you finish the task?',
            isMe: false,
            timestamp: now.subtract(const Duration(hours: 3)),
          ),
          MessageModel(
            id: 'msg_j2',
            text: 'Almost done, sending it tonight.',
            isMe: true,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
            status: MessageStatus.delivered,
          ),
          MessageModel(
            id: 'msg_j3',
            text: 'Great, let me know when it is ready.',
            isMe: false,
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
    ];
  }
}
