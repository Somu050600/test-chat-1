import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> members;
  final Map<String, bool> membersMap;
  final String lastMessage;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.members,
    required this.membersMap,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ConversationModel.fromMap(String id, Map<String, dynamic> map) {
    final members = List<String>.from(map['members'] ?? []);
    final membersMap = Map<String, bool>.from(map['membersMap'] ?? {});
    if (membersMap.isEmpty && members.isNotEmpty) {
      for (final uid in members) {
        membersMap[uid] = true;
      }
    }

    return ConversationModel(
      id: id,
      members: members,
      membersMap: membersMap,
      lastMessage: map['lastMessage'] as String? ?? '',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members,
      'membersMap': membersMap,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String otherMember(String currentUid) {
    return members.firstWhere((m) => m != currentUid, orElse: () => '');
  }
}
