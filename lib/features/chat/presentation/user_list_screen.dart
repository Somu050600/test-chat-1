import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/chat_repository.dart';
import '../../../providers/service_providers.dart';
import '../../../routes/app_router.dart';

final otherUsersProvider = StreamProvider((ref) {
  final authAsync = ref.watch(authStateProvider);
  final repo = ref.watch(userRepositoryProvider);
  return authAsync.when(
    data: (user) {
      final uid = user?.uid;
      if (uid == null) return const Stream.empty();
      return repo.watchAllUsersExcept(uid);
    },
    loading: () => const Stream.empty(),
    error: (Object e, StackTrace st) => const Stream.empty(),
  );
});

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(otherUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newChat)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${AppStrings.errorGeneric}\n$e')),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text(AppStrings.noUsers));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final u = users[i];
              return ListTile(
                leading: CircleAvatar(
                  child: u.photoUrl != null
                      ? null
                      : Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?'),
                ),
                title: Text(u.name),
                subtitle: Text(u.email),
                onTap: () {
                  final me = ref.read(firebaseAuthProvider).currentUser?.uid;
                  if (me == null) return;
                  final id = ChatRepository.conversationIdForPair(me, u.uid);
                  context.pushReplacement(AppRoutePaths.chat(id));
                },
              );
            },
          );
        },
      ),
    );
  }
}
