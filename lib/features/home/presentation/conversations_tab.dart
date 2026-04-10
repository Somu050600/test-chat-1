import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/conversation_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/chat_providers.dart';
import '../../../core/utils/date_utils.dart';

class ConversationsTab extends ConsumerWidget {
  const ConversationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUid =
        ref.watch(authStateProvider).valueOrNull?.uid ?? '';

    return conversationsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (conversations) {
        if (conversations.isEmpty) {
          return _EmptyState();
        }
        return ListView.separated(
          itemCount: conversations.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final conv = conversations[index];
            final otherUid =
                conv.members.firstWhere((id) => id != currentUid,
                    orElse: () => '');
            return _ConversationTile(
              conversation: conv,
              otherUid: otherUid,
            );
          },
        );
      },
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final ConversationModel conversation;
  final String otherUid;

  const _ConversationTile({
    required this.conversation,
    required this.otherUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserAsync = ref.watch(otherUserProvider(otherUid));

    return otherUserAsync.when(
      loading: () => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: SizedBox(
          height: 14,
          width: 80,
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return _buildTile(context, user);
      },
    );
  }

  Widget _buildTile(BuildContext context, UserModel user) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundImage:
            user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.lastMessage.isEmpty
            ? 'Tap to start chatting'
            : conversation.lastMessage,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        ChatDateUtils.formatConversationTime(conversation.updatedAt),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      onTap: () => context.push(
        '/chat/${conversation.id}'
        '?uid=${user.uid}'
        '&name=${Uri.encodeComponent(user.name)}'
        '${user.photoUrl != null ? '&photo=${Uri.encodeComponent(user.photoUrl!)}' : ''}',
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 72,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the search icon to find someone to chat with.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.outlineVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
