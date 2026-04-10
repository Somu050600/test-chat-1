import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> members;
  final String lastMessage;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.members,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      members: List<String>.from(data['members'] as List? ?? []),
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'members': members,
        'lastMessage': lastMessage,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
