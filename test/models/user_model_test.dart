import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates correct model', () {
      final now = DateTime(2024, 1, 1);
      final map = {
        'uid': 'test-uid',
        'name': 'Test User',
        'email': 'test@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': Timestamp.fromDate(now),
        'lastSeen': Timestamp.fromDate(now),
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'test-uid');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.createdAt, now);
      expect(user.lastSeen, now);
    });

    test('toMap produces correct map', () {
      final now = DateTime(2024, 1, 1);
      final user = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: '',
        createdAt: now,
        lastSeen: now,
      );

      final map = user.toMap();

      expect(map['uid'], 'test-uid');
      expect(map['name'], 'Test User');
      expect(map['email'], 'test@example.com');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('fromMap handles missing fields with defaults', () {
      final user = UserModel.fromMap({});

      expect(user.uid, '');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.photoUrl, '');
    });

    test('copyWith creates new instance with updated fields', () {
      final user = UserModel(
        uid: 'uid1',
        name: 'Name',
        email: 'email@test.com',
        photoUrl: '',
        createdAt: DateTime(2024, 1, 1),
        lastSeen: DateTime(2024, 1, 1),
      );

      final updated = user.copyWith(name: 'New Name');

      expect(updated.name, 'New Name');
      expect(updated.uid, 'uid1');
      expect(updated.email, 'email@test.com');
    });
  });
}
