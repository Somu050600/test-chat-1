import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../models/chat_message.dart';
import '../../../providers/service_providers.dart';

final messagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchMessages(conversationId);
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  bool _loadingMore = false;
  List<ChatMessage> _extraOlder = [];
  bool _ensuredConversation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureConversation());
  }

  Future<void> _ensureConversation() async {
    if (_ensuredConversation) return;
    final me = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (me == null) return;
    final parts = widget.conversationId.split('_');
    if (parts.length != 2 || !parts.contains(me)) return;
    _ensuredConversation = true;
    try {
      await ref.read(chatRepositoryProvider).ensureConversation(
            conversationId: widget.conversationId,
            members: parts,
          );
    } catch (_) {
      _ensuredConversation = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    final parts = widget.conversationId.split('_');
    if (parts.length != 2) return;
    final members = [...parts]..sort();

    setState(() => _sending = true);
    _controller.clear();
    try {
      await ref.read(chatRepositoryProvider).sendTextMessage(
            sender: user,
            conversationId: widget.conversationId,
            members: members,
            text: text,
          );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    final stream = ref.read(messagesProvider(widget.conversationId)).value ??
        const <ChatMessage>[];
    if (stream.length < 30 && _extraOlder.isEmpty) return;

    DateTime? before;
    if (_extraOlder.isNotEmpty) {
      before = _extraOlder.last.createdAt;
    } else if (stream.isNotEmpty) {
      before = stream.last.createdAt;
    }
    if (before == null) return;

    setState(() => _loadingMore = true);
    try {
      final more = await ref.read(chatRepositoryProvider).loadMessagesPage(
            conversationId: widget.conversationId,
            before: before,
            limit: 30,
          );
      if (more.isEmpty || !mounted) return;
      setState(() => _extraOlder = [..._extraOlder, ...more]);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authStateProvider).value?.uid;
    final async = ref.watch(messagesProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appTitle)),
      body: Column(
        children: [
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('${AppStrings.errorGeneric}\n$e')),
              data: (streamMessages) {
                final merged = [...streamMessages, ..._extraOlder];
                // Deduplicate by id (stream wins)
                final byId = <String, ChatMessage>{};
                for (final m in merged.reversed) {
                  byId[m.id] = m;
                }
                final list = byId.values.toList()
                  ..sort((a, b) {
                    final ta = a.createdAt;
                    final tb = b.createdAt;
                    if (ta == null && tb == null) return 0;
                    if (ta == null) return -1;
                    if (tb == null) return 1;
                    return ta.compareTo(tb);
                  });

                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSay hello!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) {
                    _scroll.jumpTo(_scroll.position.maxScrollExtent);
                  }
                });

                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels <= 80 &&
                        n is ScrollUpdateNotification) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: list.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_loadingMore && i == 0) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final idx = _loadingMore ? i - 1 : i;
                      final m = list[idx];
                      final mine = me != null && m.isFrom(me);
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: mine
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(mine ? 16 : 4),
                              bottomRight: Radius.circular(mine ? 4 : 16),
                            ),
                          ),
                          child: Text(
                            m.text,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: AppStrings.messageHint,
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    tooltip: AppStrings.send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
