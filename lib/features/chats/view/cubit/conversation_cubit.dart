import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/chat_storage_service.dart';
import '../../../../core/services/simulated_reply_service.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  ConversationCubit({
    required String email,
    required String chatId,
    ChatStorageService? chatStorageService,
  })  : _email = email,
        _chatId = chatId,
        _chatStorageService =
            chatStorageService ?? getIt<ChatStorageService>(),
        super(const ConversationState());

  final String _email;
  final String _chatId;
  final ChatStorageService _chatStorageService;

  Future<void> loadChat() async {
    emit(state.copyWith(status: ConversationStatus.loading, errorMessage: null));

    try {
      await _chatStorageService.markChatAsRead(_email, _chatId);
      final chat = _chatStorageService.getChatById(_email, _chatId);

      if (chat == null) {
        emit(
          state.copyWith(
            status: ConversationStatus.failure,
            errorMessage: 'Chat not found.',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ConversationStatus.loaded,
          chat: chat,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ConversationStatus.failure,
          errorMessage: 'Could not load conversation.',
        ),
      );
    }
  }

  Future<void> sendMessage({String? text, String? emoji}) async {
    final trimmedText = text?.trim() ?? '';
    if (trimmedText.isEmpty && emoji == null) return;

    final chat = state.chat;
    if (chat == null) return;

    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final message = MessageModel(
      id: messageId,
      text: emoji != null ? '' : trimmedText,
      emoji: emoji,
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    final optimisticChat = chat.copyWith(
      messages: [...chat.messages, message],
      updatedAt: DateTime.now(),
    );

    emit(
      state.copyWith(
        chat: optimisticChat,
        status: ConversationStatus.loaded,
      ),
    );

    _scheduleSimulatedReply(
      userText: emoji != null ? '' : trimmedText,
      userEmoji: emoji,
    );

    await _chatStorageService.upsertChat(_email, optimisticChat);

    final sentChat = _withMessageStatus(messageId, MessageStatus.sent);
    if (sentChat == null) return;

    await _chatStorageService.upsertChat(_email, sentChat);
    emit(state.copyWith(chat: sentChat));

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (isClosed) return;

    final deliveredChat = _withMessageStatus(messageId, MessageStatus.delivered);
    if (deliveredChat == null) return;

    await _chatStorageService.upsertChat(_email, deliveredChat);
    emit(state.copyWith(chat: deliveredChat));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  ChatModel? _withMessageStatus(String messageId, MessageStatus status) {
    final chat = state.chat;
    if (chat == null) return null;

    final messages = chat.messages.map((message) {
      if (message.id != messageId) return message;
      return message.copyWith(status: status);
    }).toList();

    return chat.copyWith(messages: messages, updatedAt: DateTime.now());
  }

  Future<void> _scheduleSimulatedReply({
    required String userText,
    String? userEmoji,
  }) async {
    emit(state.copyWith(isTyping: true));

    await Future<void>.delayed(const Duration(seconds: 2));
    if (isClosed) return;

    emit(state.copyWith(isTyping: false));

    final chat = state.chat;
    if (chat == null) return;

    final reply = SimulatedReplyService.buildReply(
      userText: userText,
      userEmoji: userEmoji,
    );

    final updatedChat = chat.copyWith(
      messages: [...chat.messages, reply],
      updatedAt: DateTime.now(),
    );

    await _chatStorageService.upsertChat(_email, updatedChat);
    if (isClosed) return;

    emit(state.copyWith(chat: updatedChat));
  }
}
