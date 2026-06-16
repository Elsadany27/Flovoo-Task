import '../../core/constants/hive_constants.dart';

import '../../features/chats/data/models/chat_model.dart';
import '../../features/chats/data/seed/default_chats.dart';
import 'hive_service.dart';

class ChatStorageService {
  ChatStorageService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  List<ChatModel> getChatsForEmail(String email) {
    final key = HiveConstants.chatsKeyForEmail(email);
    final raw = _hiveService.chatsBox.get(key);
    return _parseChatList(raw);
  }

  ChatModel? getChatById(String email, String chatId) {
    final chats = getChatsForEmail(email);
    for (final chat in chats) {
      if (chat.id == chatId) return chat;
    }
    return null;
  }

  Future<void> saveChatsForEmail(String email, List<ChatModel> chats) async {
    final key = HiveConstants.chatsKeyForEmail(email);
    await _hiveService.chatsBox.put(key, List<ChatModel>.from(chats));
  }

  Future<void> ensureDefaultChats(String email) async {
    try {
      final chats = getChatsForEmail(email);
      if (chats.isNotEmpty) return;

      await saveChatsForEmail(email, DefaultChats.create());
    } catch (_) {
      await _resetChatsForEmail(email);
    }
  }

  Future<void> upsertChat(String email, ChatModel chat) async {
    final chats = List<ChatModel>.from(getChatsForEmail(email));
    final index = chats.indexWhere((item) => item.id == chat.id);

    if (index >= 0) {
      chats[index] = chat;
    } else {
      chats.add(chat);
    }

    chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await saveChatsForEmail(email, chats);
  }

  Future<void> markChatAsRead(String email, String chatId) async {
    final chat = getChatById(email, chatId);
    if (chat == null || chat.unreadCount == 0) return;

    await upsertChat(email, chat.copyWith(unreadCount: 0));
  }

  Future<void> _resetChatsForEmail(String email) async {
    final key = HiveConstants.chatsKeyForEmail(email);
    await _hiveService.chatsBox.delete(key);
    await saveChatsForEmail(email, DefaultChats.create());
  }

  List<ChatModel> _parseChatList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List<ChatModel>) {
      return List<ChatModel>.from(raw);
    }

    if (raw is List) {
      final parsed = <ChatModel>[];
      for (final item in raw) {
        if (item is ChatModel) {
          parsed.add(item);
        }
      }
      return parsed;
    }

    return [];
  }
}
