import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/theme_service.dart';
import '../cubit/conversation_cubit.dart';
import '../cubit/conversation_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.email,
    required this.chatId,
  });

  final String email;
  final String chatId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showSearch = false;

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _firstName(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return 'Someone';
    return trimmed.split(' ').first;
  }

  void _toggleSearch(ConversationCubit cubit) {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        cubit.setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConversationCubit(
        email: widget.email,
        chatId: widget.chatId,
      )..loadChat(),
      child: BlocConsumer<ConversationCubit, ConversationState>(
        listenWhen: (previous, current) =>
            previous.chat?.messages.length != current.chat?.messages.length ||
            previous.isTyping != current.isTyping ||
            previous.status != current.status,
        listener: (context, state) {
          if (state.status == ConversationStatus.loaded) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state.status == ConversationStatus.loading ||
              state.status == ConversationStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == ConversationStatus.failure || state.chat == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(state.errorMessage ?? 'Chat not found'),
              ),
            );
          }

          final chat = state.chat!;
          final cubit = context.read<ConversationCubit>();
          final contactFirstName = _firstName(chat.title);
          final messages = state.visibleMessages;
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: Text(
                      chat.title.isNotEmpty
                          ? chat.title[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          state.isTyping
                              ? '$contactFirstName is typing...'
                              : 'Online',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: state.isTyping
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    fontStyle: state.isTyping
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => _toggleSearch(cubit),
                  icon: Icon(_showSearch ? Icons.close : Icons.search),
                  tooltip: _showSearch ? 'Close search' : 'Search messages',
                ),
                IconButton(
                  onPressed: () => getIt<ThemeService>().toggleTheme(),
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  tooltip: 'Toggle theme',
                ),
              ],
            ),
            body: Column(
              children: [
                if (_showSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  cubit.setSearchQuery('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        cubit.setSearchQuery(value);
                        setState(() {});
                      },
                    ),
                  ),
                Expanded(
                  child: messages.isEmpty && state.searchQuery.isNotEmpty
                      ? const Center(child: Text('No messages found'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(message: messages[index]);
                          },
                        ),
                ),
                if (state.isTyping)
                  TypingIndicator(contactName: contactFirstName),
                MessageInput(
                  controller: _messageController,
                  onSend: () {
                    cubit.sendMessage(text: _messageController.text);
                    _messageController.clear();
                  },
                  onEmojiSelected: (emoji) {
                    cubit.sendMessage(emoji: emoji);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
