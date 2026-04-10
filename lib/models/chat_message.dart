import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, read }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final MessageStatus status;

  bool isFrom(String uid) => senderId == uid;

  static MessageStatus _parseStatus(String? s) {
    switch (s) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'sent':
      default:
        return MessageStatus.sent;
    }
  }

  static ChatMessage? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    final ts = data['createdAt'];
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: ts is Timestamp ? ts.toDate() : null,
      status: _parseStatus(data['status'] as String?),
    );
  }
}
