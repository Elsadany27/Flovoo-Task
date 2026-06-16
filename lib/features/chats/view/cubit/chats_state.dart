import 'package:equatable/equatable.dart';
import '../../data/models/chat_model.dart';

enum ChatsStatus { initial, loading, loaded, failure }

class ChatsState extends Equatable {
  const ChatsState({
    this.status = ChatsStatus.initial,
    this.chats = const [],
    this.errorMessage,
    this.searchQuery = '',
  });

  final ChatsStatus status;
  final List<ChatModel> chats;
  final String? errorMessage;
  final String searchQuery;

  List<ChatModel> get filteredChats {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return chats;

    return chats.where((chat) {
      if (chat.title.toLowerCase().contains(query)) return true;
      if (chat.lastMessagePreview.toLowerCase().contains(query)) return true;
      return chat.messages.any(
        (message) =>
            message.text.toLowerCase().contains(query) ||
            (message.emoji?.contains(query) ?? false),
      );
    }).toList();
  }

  ChatsState copyWith({
    ChatsStatus? status,
    List<ChatModel>? chats,
    String? errorMessage,
    String? searchQuery,
  }) {
    return ChatsState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [status, chats, errorMessage, searchQuery];
}
