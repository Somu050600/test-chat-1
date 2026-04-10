import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'auth_providers.dart';
import 'service_providers.dart';

final conversationsProvider =
    StreamProvider<List<ConversationModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref
          .watch(firestoreServiceProvider)
          .conversationsStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (error, stack) => Stream.value([]),
  );
});

/// Provides messages for a specific conversation.
final messagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref
      .watch(firestoreServiceProvider)
      .messagesStream(conversationId);
});

/// Resolves the "other" user in a conversation.
final otherUserProvider =
    FutureProvider.family<UserModel?, String>((ref, otherUid) {
  return ref.watch(firestoreServiceProvider).getUser(otherUid);
});

/// Search users by query string.
final userSearchProvider =
    StreamProvider.family<List<UserModel>, String>((ref, query) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref
          .watch(firestoreServiceProvider)
          .searchUsers(query, user.uid);
    },
    loading: () => Stream.value([]),
    error: (error, stack) => Stream.value([]),
  );
});
