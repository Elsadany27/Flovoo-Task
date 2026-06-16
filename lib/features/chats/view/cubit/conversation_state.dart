import 'package:equatable/equatable.dart';

import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';

enum ConversationStatus { initial, loading, loaded, failure }

class ConversationState extends Equatable {
  const ConversationState({
    this.status = ConversationStatus.initial,
    this.chat,
    this.errorMessage,
    this.isTyping = false,
    this.searchQuery = '',
  });

  final ConversationStatus status;
  final ChatModel? chat;
  final String? errorMessage;
  final bool isTyping;
  final String searchQuery;

  List<MessageModel> get visibleMessages {
    final messages = chat?.messages ?? const [];
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return messages;

    return messages.where((message) {
      if (message.text.toLowerCase().contains(query)) return true;
      return message.emoji?.contains(query) ?? false;
    }).toList();
  }

  ConversationState copyWith({
    ConversationStatus? status,
    ChatModel? chat,
    String? errorMessage,
    bool? isTyping,
    String? searchQuery,
  }) {
    return ConversationState(
      status: status ?? this.status,
      chat: chat ?? this.chat,
      errorMessage: errorMessage,
      isTyping: isTyping ?? this.isTyping,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [status, chat, errorMessage, isTyping, searchQuery];
}
