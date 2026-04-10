import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.members,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final List<String> members;
  final String lastMessage;
  final DateTime? updatedAt;

  String? peerId(String currentUid) {
    for (final m in members) {
      if (m != currentUid) return m;
    }
    return null;
  }

  static Conversation? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    final members = (data['members'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];
    final ts = data['updatedAt'];
    return Conversation(
      id: doc.id,
      members: members,
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
