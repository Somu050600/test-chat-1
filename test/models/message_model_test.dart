import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('fromMap creates correct model with server and client timestamps', () {
      final serverTime = DateTime(2024, 1, 1, 12, 0);
      final clientTime = DateTime(2024, 1, 1, 11, 59);
      final map = {
        'senderId': 'uid1',
        'text': 'Hello!',
        'createdAt': Timestamp.fromDate(serverTime),
        'clientTimestamp': Timestamp.fromDate(clientTime),
        'status': 'sent',
      };

      final message = MessageModel.fromMap('msg-id', map);

      expect(message.id, 'msg-id');
      expect(message.senderId, 'uid1');
      expect(message.text, 'Hello!');
      expect(message.createdAt, serverTime);
      expect(message.clientTimestamp, clientTime);
      expect(message.status, MessageStatus.sent);
    });

    test('fromMap falls back to clientTimestamp when createdAt is null', () {
      final clientTime = DateTime(2024, 1, 1, 12, 0);
      final map = {
        'senderId': 'uid1',
        'text': 'Hello!',
        'createdAt': null,
        'clientTimestamp': Timestamp.fromDate(clientTime),
        'status': 'sent',
      };

      final message = MessageModel.fromMap('id', map);
      expect(message.createdAt, clientTime);
    });

    test('toMap uses FieldValue.serverTimestamp for createdAt', () {
      final now = DateTime(2024, 1, 1);
      final message = MessageModel(
        id: 'id',
        senderId: 'uid1',
        text: 'Hi',
        createdAt: now,
        clientTimestamp: now,
        status: MessageStatus.read,
      );

      final map = message.toMap();

      expect(map['senderId'], 'uid1');
      expect(map['text'], 'Hi');
      expect(map['status'], 'read');
      expect(map['createdAt'], isA<FieldValue>());
      expect(map['clientTimestamp'], isA<Timestamp>());
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
