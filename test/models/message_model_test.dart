import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime(2024, 1, 1);
      final map = {
        'senderId': 'uid1',
        'text': 'Hello!',
        'createdAt': Timestamp.fromDate(now),
        'status': 'sent',
      };

      final message = MessageModel.fromMap('msg-id', map);

      expect(message.id, 'msg-id');
      expect(message.senderId, 'uid1');
      expect(message.text, 'Hello!');
      expect(message.createdAt, now);
      expect(message.status, MessageStatus.sent);
    });

    test('toMap produces correct map', () {
      final message = MessageModel(
        id: 'id',
        senderId: 'uid1',
        text: 'Hi',
        createdAt: DateTime(2024, 1, 1),
        status: MessageStatus.read,
      );

      final map = message.toMap();

      expect(map['senderId'], 'uid1');
      expect(map['text'], 'Hi');
      expect(map['status'], 'read');
    });

    test('fromMap handles unknown status', () {
      final map = {
        'senderId': 'uid1',
        'text': 'Hello',
        'status': 'unknown_value',
      };

      final message = MessageModel.fromMap('id', map);
      expect(message.status, MessageStatus.sent);
    });

    test('fromMap handles missing fields', () {
      final message = MessageModel.fromMap('id', {});

      expect(message.senderId, '');
      expect(message.text, '');
      expect(message.status, MessageStatus.sent);
    });
  });
}
