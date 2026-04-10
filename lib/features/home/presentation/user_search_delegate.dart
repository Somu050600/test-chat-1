import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/chat_providers.dart';
import '../../../providers/service_providers.dart';

class UserSearchDelegate extends SearchDelegate<UserModel?> {
  final WidgetRef ref;

  UserSearchDelegate(this.ref)
      : super(searchFieldLabel: 'Search by name or email…');

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _SearchResults(
        query: query,
        ref: ref,
        onUserTap: (user) => _openChat(context, user),
      );

  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(
        query: query,
        ref: ref,
        onUserTap: (user) => _openChat(context, user),
      );

  Future<void> _openChat(BuildContext context, UserModel user) async {
    close(context, null);
    final currentUid =
        ref.read(authStateProvider).valueOrNull?.uid ?? '';
    final conversationId = await ref
        .read(firestoreServiceProvider)
        .getOrCreateConversation(currentUid, user.uid);

    if (context.mounted) {
      context.push(
        '/chat/$conversationId'
        '?uid=${user.uid}'
        '&name=${Uri.encodeComponent(user.name)}'
        '${user.photoUrl != null ? '&photo=${Uri.encodeComponent(user.photoUrl!)}' : ''}',
      );
    }
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final WidgetRef ref;
  final void Function(UserModel) onUserTap;

  const _SearchResults({
    required this.query,
    required this.ref,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          'Type a name or email to search.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final usersAsync = ref.watch(userSearchProvider(query));
    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users found for "$query".',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : '?')
                    : null,
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              onTap: () => onUserTap(user),
            );
          },
        );
      },
    );
  }
}
