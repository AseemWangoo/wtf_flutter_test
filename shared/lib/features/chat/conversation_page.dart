import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/message.dart';
import '../../models/user.dart';
import '../../providers/chat_providers.dart';
import '../../providers/service_providers.dart';
import '../../utils/app_colors.dart';
import '../../widgets/chat_empty_state.dart';
import '../../widgets/chat_input_bar.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/quick_reply_chips.dart';
import '../../widgets/typing_indicator.dart';

class ConversationPage extends ConsumerStatefulWidget {
  const ConversationPage({
    super.key,
    required this.currentUser,
    required this.peer,
    required this.chatId,
  });

  final User currentUser;
  final User peer;
  final String chatId;

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final _scrollController = ScrollController();
  int _messageCount = 0;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  Future<void> _markRead() async {
    await ref.read(chatServiceProvider).markRead(widget.chatId, widget.currentUser.id);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    try {
      await ref.read(chatServiceProvider).loadHistory(widget.chatId);
      await _markRead();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _send(String text) async {
    final send = ref.read(
      sendMessageProvider(
        sendArgsFor(widget.currentUser, widget.peer),
      ),
    );
    await send(text);
    await _markRead();
  }

  Color _bubbleColor(Message message) {
    final isMine = message.senderId == widget.currentUser.id;
    final senderRole =
        message.senderId == widget.currentUser.id ? widget.currentUser.role : widget.peer.role;
    return bubbleColorFor(senderRole, isMine: isMine);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final typingAsync = ref.watch(typingUsersProvider(widget.chatId));
    final roleLabel = widget.currentUser.role == UserRole.trainer ? 'Trainer' : 'Member';

    ref.listen(messagesProvider(widget.chatId), (prev, next) {
      final count = next.valueOrNull?.length ?? 0;
      if (count > _messageCount) {
        _messageCount = count;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        _markRead();
      }
    });

    final typingUsers = typingAsync.valueOrNull ?? {};
    final peerTyping = typingUsers.contains(widget.peer.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peer.name),
            Text(
              '$roleLabel • ${widget.peer.role == UserRole.trainer ? 'Lead Trainer' : 'Member'}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral700,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Video call (Hour 4)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call — coming in Hour 4')),
              );
            },
            icon: Badge(
              label: const Text(' '),
              smallSize: 8,
              child: const Icon(Icons.videocam_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (_messageCount == 0 && messages.isNotEmpty) {
                  _messageCount = messages.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }

                if (messages.isEmpty && !peerTyping) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.55,
                          child: ChatEmptyState(
                            onSayHi: () => _send('Hi Coach 👋'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length + (peerTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (peerTyping && index == messages.length) {
                        return const TypingIndicator();
                      }
                      final message = messages[index];
                      if (message.isSystem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.neutral100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message.text,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.neutral700,
                                    ),
                              ),
                            ),
                          ),
                        );
                      }
                      final isMine = message.senderId == widget.currentUser.id;
                      return MessageBubble(
                        message: message,
                        isMine: isMine,
                        bubbleColor: _bubbleColor(message),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_refreshing)
            const LinearProgressIndicator(minHeight: 2),
          QuickReplyChips(onSelected: _send),
          ChatInputBar(
            enabled: messagesAsync.hasValue,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}
