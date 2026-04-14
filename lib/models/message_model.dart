import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final DateTime clientTimestamp;
  final MessageStatus status;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.clientTimestamp,
    required this.status,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    final serverTime = (map['createdAt'] as Timestamp?)?.toDate();
    final clientTime = (map['clientTimestamp'] as Timestamp?)?.toDate();
    final fallback = clientTime ?? DateTime.now();

    return MessageModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAt: serverTime ?? fallback,
      clientTimestamp: clientTime ?? DateTime.now(),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String? ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'clientTimestamp': Timestamp.fromDate(clientTimestamp),
      'status': status.name,
    };
  }
}
