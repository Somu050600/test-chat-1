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

  factory ConversationModel.fromMap(String id, Map<String, dynamic> map) {
    return ConversationModel(
      id: id,
      members: List<String>.from(map['members'] ?? []),
      lastMessage: map['lastMessage'] as String? ?? '',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String otherMember(String currentUid) {
    return members.firstWhere((m) => m != currentUid, orElse: () => '');
  }
}
