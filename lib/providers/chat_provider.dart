import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/chat_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final conversationsProvider = StreamProvider<List<ConversationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(chatServiceProvider).getConversations(user.uid);
});

final messagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.watch(chatServiceProvider).getMessages(conversationId);
});

final userProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  return ref.watch(chatServiceProvider).getUser(userId);
});

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(chatServiceProvider).searchUsers(user.uid);
});
