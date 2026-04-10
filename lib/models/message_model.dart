import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.status,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _statusFromString(data['status'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'createdAt': Timestamp.fromDate(createdAt),
        'status': status.name,
      };

  static MessageStatus _statusFromString(String? value) {
    switch (value) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}
