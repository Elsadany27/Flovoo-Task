import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/theme_service.dart';
import '../../../login/view/screens/login_screen.dart';
import '../cubit/chats_cubit.dart';
import '../cubit/chats_state.dart';
import '../widgets/chat_list_item.dart';
import 'conversation_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key, required this.email});

  final String email;

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<ChatsCubit>().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _openConversation(BuildContext context, String chatId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          email: widget.email,
          chatId: chatId,
        ),
      ),
    );

    if (context.mounted) {
      await context.read<ChatsCubit>().loadChats();
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        context.read<ChatsCubit>().setSearchQuery('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatsCubit(email: widget.email)..loadChats(),
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Messages'),
                  BlocBuilder<ChatsCubit, ChatsState>(
                    builder: (context, state) {
                      if (state.status != ChatsStatus.loaded) {
                        return const SizedBox.shrink();
                      }

                      return Text(
                        widget.email,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(_showSearch ? Icons.close : Icons.search),
                  tooltip: _showSearch ? 'Close search' : 'Search conversations',
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
                IconButton(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Switch account',
                ),
              ],
            ),
            body: Column(
              children: [
                if (_showSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search conversations or messages...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<ChatsCubit>()
                                      .setSearchQuery('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        context.read<ChatsCubit>().setSearchQuery(value);
                        setState(() {});
                      },
                    ),
                  ),
                Expanded(
                  child: BlocBuilder<ChatsCubit, ChatsState>(
                    builder: (context, state) {
                      if (state.status == ChatsStatus.loading ||
                          state.status == ChatsStatus.initial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.status == ChatsStatus.failure) {
                        return _ErrorView(
                          message: state.errorMessage ?? 'Something went wrong.',
                          onRetry: () => context.read<ChatsCubit>().loadChats(),
                        );
                      }

                      final chats = state.filteredChats;

                      if (chats.isEmpty) {
                        return Center(
                          child: Text(
                            state.searchQuery.isEmpty
                                ? 'No chats yet'
                                : 'No conversations found',
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: chats.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ChatListItem(
                              chat: chat,
                              onTap: () => _openConversation(context, chat.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
