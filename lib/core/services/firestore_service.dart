import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ── Users ──────────────────────────────────────────────────────────────────

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists ? UserModel.fromFirestore(snap) : null);
  }

  Future<UserModel?> getUser(String uid) async {
    final snap =
        await _db.collection(FirestoreCollections.users).doc(uid).get();
    return snap.exists ? UserModel.fromFirestore(snap) : null;
  }

  Stream<List<UserModel>> searchUsers(String query, String currentUid) {
    if (query.trim().isEmpty) {
      return Stream.value([]);
    }
    final lowerQuery = query.toLowerCase();
    return _db
        .collection(FirestoreCollections.users)
        .snapshots()
        .map((snap) => snap.docs
            .map(UserModel.fromFirestore)
            .where((u) =>
                u.uid != currentUid &&
                (u.name.toLowerCase().contains(lowerQuery) ||
                    u.email.toLowerCase().contains(lowerQuery)))
            .toList());
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  Stream<List<ConversationModel>> conversationsStream(String uid) {
    return _db
        .collection(FirestoreCollections.conversations)
        .where('members', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ConversationModel.fromFirestore).toList());
  }

  Future<String> getOrCreateConversation(String uid1, String uid2) async {
    final snap = await _db
        .collection(FirestoreCollections.conversations)
        .where('members', arrayContains: uid1)
        .get();

    for (final doc in snap.docs) {
      final members = List<String>.from(doc['members'] as List);
      if (members.contains(uid2)) return doc.id;
    }

    final newId = _uuid.v4();
    await _db
        .collection(FirestoreCollections.conversations)
        .doc(newId)
        .set({
      'members': [uid1, uid2],
      'lastMessage': '',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    return newId;
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  Stream<List<MessageModel>> messagesStream(String conversationId) {
    return _db
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.messagePaginationLimit)
        .snapshots()
        .map((snap) =>
            snap.docs.map(MessageModel.fromFirestore).toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final batch = _db.batch();
    final messageRef = _db
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
    );

    batch.set(messageRef, message.toMap());

    final convRef = _db
        .collection(FirestoreCollections.conversations)
        .doc(conversationId);
    batch.update(convRef, {
      'lastMessage': text,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String currentUid,
  }) async {
    final snap = await _db
        .collection(FirestoreCollections.conversations)
        .doc(conversationId)
        .collection(FirestoreCollections.messages)
        .where('senderId', isNotEqualTo: currentUid)
        .where('status', isNotEqualTo: MessageStatus.read.name)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'status': MessageStatus.read.name});
    }
    await batch.commit();
  }
}
