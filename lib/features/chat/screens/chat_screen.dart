import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/message_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _markedAsRead = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _markAsRead() {
    if (_markedAsRead) return;
    _markedAsRead = true;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    ref
        .read(chatServiceProvider)
        .markMessagesAsRead(widget.conversationId, user.uid);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet.\nSend the first one!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  );
                }
                final hasUnread = messages.any(
                  (m) =>
                      m.senderId != currentUser?.uid &&
                      m.status != MessageStatus.read,
                );
                if (hasUnread) {
                  _markedAsRead = false;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _markAsRead());
                } else if (!_markedAsRead) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _markAsRead());
                }
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;
                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          MessageInput(
            onSend: (text) async {
              if (currentUser == null) return;
              await ref.read(chatServiceProvider).sendMessage(
                    conversationId: widget.conversationId,
                    senderId: currentUser.uid,
                    text: text,
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    final currentUser = ref.watch(currentUserProvider);
    final convosAsync = ref.watch(conversationsProvider);

    return convosAsync.when(
      data: (convos) {
        final convo = convos.where((c) => c.id == widget.conversationId);
        if (convo.isEmpty) return const Text('Chat');
        final otherUid = convo.first.otherMember(currentUser?.uid ?? '');
        final userAsync = ref.watch(userProvider(otherUid));
        return userAsync.when(
          data: (user) => Text(user?.name ?? 'Chat'),
          loading: () => const Text('Loading...'),
          error: (e, s) => const Text('Chat'),
        );
      },
      loading: () => const Text('Loading...'),
      error: (e, s) => const Text('Chat'),
    );
  }
}
