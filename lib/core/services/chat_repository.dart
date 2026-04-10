import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import '../constants/firestore_paths.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Deterministic id for a 1:1 thread (two member uids sorted).
  static String conversationIdForPair(String a, String b) {
    final pair = [a, b]..sort();
    return '${pair[0]}_${pair[1]}';
  }

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _db.collection(FirestorePaths.conversations);

  Stream<List<Conversation>> watchMyConversations(String uid) {
    return _conversations
        .where('members', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map(Conversation.fromDoc)
          .whereType<Conversation>()
          .toList();
    });
  }

  Stream<List<ChatMessage>> watchMessages(
    String conversationId, {
    int limit = 30,
  }) {
    return _conversations
        .doc(conversationId)
        .collection(FirestorePaths.messages)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map(ChatMessage.fromDoc)
          .whereType<ChatMessage>()
          .toList();
    });
  }

  /// Loads older messages before [before] (exclusive), for pagination.
  Future<List<ChatMessage>> loadMessagesPage({
    required String conversationId,
    required DateTime before,
    int limit = 30,
  }) async {
    final q = await _conversations
        .doc(conversationId)
        .collection(FirestorePaths.messages)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(before)])
        .limit(limit)
        .get();
    return q.docs.map(ChatMessage.fromDoc).whereType<ChatMessage>().toList();
  }

  /// Must run before the first message so security rules can read `members`
  /// (batch writes do not see uncommitted sibling docs).
  Future<void> ensureConversation({
    required String conversationId,
    required List<String> members,
  }) async {
    final sorted = [...members]..sort();
    await _conversations.doc(conversationId).set(
      {
        'members': sorted,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> sendTextMessage({
    required User sender,
    required String conversationId,
    required List<String> members,
    required String text,
  }) async {
    final batch = _db.batch();
    final convRef = _conversations.doc(conversationId);
    final msgRef = convRef.collection(FirestorePaths.messages).doc();
    final now = FieldValue.serverTimestamp();
    final sorted = [...members]..sort();

    batch.set(
      convRef,
      {
        'members': sorted,
        'lastMessage': text,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    batch.set(msgRef, {
      'senderId': sender.uid,
      'text': text,
      'createdAt': now,
      'status': 'sent',
    });

    await batch.commit();
  }
}
