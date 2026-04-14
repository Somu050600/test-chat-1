import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromMap creates correct model with isOnline', () {
      final now = DateTime(2024, 1, 1);
      final map = {
        'uid': 'test-uid',
        'name': 'Test User',
        'email': 'test@example.com',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': Timestamp.fromDate(now),
        'lastSeen': Timestamp.fromDate(now),
        'isOnline': true,
      };

      final user = UserModel.fromMap(map);

      expect(user.uid, 'test-uid');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
      expect(user.createdAt, now);
      expect(user.lastSeen, now);
      expect(user.isOnline, isTrue);
    });

    test('toMap includes isOnline', () {
      final now = DateTime(2024, 1, 1);
      final user = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        photoUrl: '',
        createdAt: now,
        lastSeen: now,
        isOnline: true,
      );

      final map = user.toMap();

      expect(map['uid'], 'test-uid');
      expect(map['isOnline'], isTrue);
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('fromMap defaults isOnline to false', () {
      final user = UserModel.fromMap({});

      expect(user.uid, '');
      expect(user.name, '');
      expect(user.isOnline, isFalse);
    });

    test('isRecentlyOnline returns true when online', () {
      final user = UserModel(
        uid: 'uid1',
        name: 'Name',
        email: 'e@t.com',
        photoUrl: '',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      expect(user.isRecentlyOnline, isTrue);
      expect(user.presenceText, 'Online');
    });

    test('isRecentlyOnline returns true when lastSeen < 30s ago', () {
      final user = UserModel(
        uid: 'uid1',
        name: 'Name',
        email: 'e@t.com',
        photoUrl: '',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now().subtract(const Duration(seconds: 10)),
        isOnline: false,
      );

      expect(user.isRecentlyOnline, isTrue);
    });

    test('isRecentlyOnline returns false when lastSeen > 30s ago', () {
      final user = UserModel(
        uid: 'uid1',
        name: 'Name',
        email: 'e@t.com',
        photoUrl: '',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        isOnline: false,
      );

      expect(user.isRecentlyOnline, isFalse);
      expect(user.presenceText, 'Last seen 5m ago');
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

      final updated = user.copyWith(name: 'New Name', isOnline: true);

      expect(updated.name, 'New Name');
      expect(updated.uid, 'uid1');
      expect(updated.isOnline, isTrue);
    });
  });
}
