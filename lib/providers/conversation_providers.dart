import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../models/conversation.dart';
import 'service_providers.dart';

final conversationListProvider = StreamProvider<List<Conversation>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final chat = ref.watch(chatRepositoryProvider);
  return authAsync.when(
    data: (user) {
      final uid = user?.uid;
      if (uid == null) return const Stream.empty();
      return chat.watchMyConversations(uid);
    },
    loading: () => const Stream.empty(),
    error: (Object e, StackTrace st) => const Stream.empty(),
  );
});

final peerUserProvider = FutureProvider.family<AppUser?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUser(uid);
});
