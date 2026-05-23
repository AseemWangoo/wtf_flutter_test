import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chat_thread.dart';
import '../../models/user.dart';
import '../../providers/chat_providers.dart';
import '../../widgets/chat_list_tile.dart';
import 'conversation_page.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({
    super.key,
    required this.currentUser,
    required this.primaryColor,
  });

  final User currentUser;
  final Color primaryColor;

  void _openConversation(BuildContext context, ChatThread thread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          currentUser: currentUser,
          peer: thread.peer,
          chatId: thread.chatId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(chatThreadsProvider(currentUser));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (threads.isNotEmpty) {
            _openConversation(context, threads.first);
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final thread = threads[index];
          return ChatListTileWidget(
            thread: thread,
            onTap: () => _openConversation(context, thread),
          );
        },
      ),
    );
  }
}
