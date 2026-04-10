import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/conversation_model.dart';

void main() {
  group('ConversationModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime(2024, 1, 1);
      final map = {
        'members': ['uid1', 'uid2'],
        'lastMessage': 'Hello!',
        'updatedAt': Timestamp.fromDate(now),
      };

      final convo = ConversationModel.fromMap('convo-id', map);

      expect(convo.id, 'convo-id');
      expect(convo.members, ['uid1', 'uid2']);
      expect(convo.lastMessage, 'Hello!');
      expect(convo.updatedAt, now);
    });

    test('toMap produces correct map', () {
      final convo = ConversationModel(
        id: 'id',
        members: ['uid1', 'uid2'],
        lastMessage: 'Hi',
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = convo.toMap();

      expect(map['members'], ['uid1', 'uid2']);
      expect(map['lastMessage'], 'Hi');
    });

    test('otherMember returns the other uid', () {
      final convo = ConversationModel(
        id: 'id',
        members: ['uid1', 'uid2'],
        lastMessage: '',
        updatedAt: DateTime.now(),
      );

      expect(convo.otherMember('uid1'), 'uid2');
      expect(convo.otherMember('uid2'), 'uid1');
    });

    test('fromMap handles missing fields', () {
      final convo = ConversationModel.fromMap('id', {});

      expect(convo.members, isEmpty);
      expect(convo.lastMessage, '');
    });
  });
}
