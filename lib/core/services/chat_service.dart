import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('members', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<MessageModel>> getMessages(
    String conversationId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final now = DateTime.now();
    final message = MessageModel(
      id: '',
      senderId: senderId,
      text: text,
      createdAt: now,
      status: MessageStatus.sent,
    );

    final batch = _firestore.batch();

    final msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();
    batch.set(msgRef, message.toMap());

    final convoRef =
        _firestore.collection('conversations').doc(conversationId);
    batch.update(convoRef, {
      'lastMessage': text,
      'updatedAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  Future<String> getOrCreateConversation(
      String currentUserId, String otherUserId) async {
    final query = await _firestore
        .collection('conversations')
        .where('members', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final members = List<String>.from(doc.data()['members'] ?? []);
      if (members.contains(otherUserId) && members.length == 2) {
        return doc.id;
      }
    }

    final newConvo = await _firestore.collection('conversations').add(
      ConversationModel(
        id: '',
        members: [currentUserId, otherUserId],
        lastMessage: '',
        updatedAt: DateTime.now(),
      ).toMap(),
    );

    return newConvo.id;
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Stream<List<UserModel>> searchUsers(String currentUserId) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  }

  Future<void> markMessagesAsRead(
      String conversationId, String currentUserId) async {
    final unread = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('status', isEqualTo: 'sent')
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      if (doc.data()['senderId'] != currentUserId) {
        batch.update(doc.reference, {'status': 'read'});
      }
    }
    await batch.commit();
  }
}
