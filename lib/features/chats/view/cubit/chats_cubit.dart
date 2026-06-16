import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/chat_storage_service.dart';
import '../../../../core/services/session_service.dart';
import 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({
    required String email,
    ChatStorageService? chatStorageService,
    SessionService? sessionService,
  })  : _email = email,
        _chatStorageService =
            chatStorageService ?? getIt<ChatStorageService>(),
        _sessionService = sessionService ?? getIt<SessionService>(),
        super(const ChatsState());

  final String _email;
  final ChatStorageService _chatStorageService;
  final SessionService _sessionService;

  String get email => _email;

  Future<void> loadChats() async {
    emit(state.copyWith(status: ChatsStatus.loading, errorMessage: null));

    try {
      await _chatStorageService.ensureDefaultChats(_email);
      final chats = _chatStorageService.getChatsForEmail(_email);

      emit(
        state.copyWith(
          status: ChatsStatus.loaded,
          chats: chats,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ChatsStatus.failure,
          errorMessage: 'Could not load chats. Please try again.',
        ),
      );
    }
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }
}
