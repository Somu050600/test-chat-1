import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../providers/conversation_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../routes/app_router.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final async = ref.watch(conversationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.conversations),
        actions: [
          if (uid != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: AppStrings.signOut,
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  context.go(AppRoutePaths.login);
                }
              },
            ),
        ],
      ),
      body: uid == null
          ? Center(
              child: FilledButton(
                onPressed: () => context.go(AppRoutePaths.login),
                child: const Text(AppStrings.signInWithGoogle),
              ),
            )
          : async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${AppStrings.errorGeneric}\n$e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      AppStrings.noConversations,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final peerId = c.peerId(uid);
                    final titleAsync = peerId != null
                        ? ref.watch(peerUserProvider(peerId))
                        : null;
                    final title = titleAsync?.value?.name ?? peerId ?? c.id;
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(
                        c.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: c.updatedAt != null
                          ? Text(
                              _shortTime(c.updatedAt!),
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          : null,
                      onTap: () =>
                          context.push(AppRoutePaths.chat(c.id)),
                    );
                  },
                );
              },
            ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutePaths.people),
              child: const Icon(Icons.add),
            ),
    );
  }

  static String _shortTime(DateTime t) {
    final now = DateTime.now();
    if (now.difference(t).inDays < 1) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    return '${t.month}/${t.day}';
  }
}
