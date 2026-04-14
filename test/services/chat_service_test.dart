import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/core/services/chat_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ChatService chatService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    chatService = ChatService(firestore: fakeFirestore);
  });

  group('ChatService', () {
    test('getOrCreateConversation creates new conversation', () async {
      final id = await chatService.getOrCreateConversation('uid1', 'uid2');

      expect(id, isNotEmpty);

      final doc =
          await fakeFirestore.collection('conversations').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['members'], ['uid1', 'uid2']);
    });

    test('getOrCreateConversation returns existing conversation', () async {
      final first = await chatService.getOrCreateConversation('uid1', 'uid2');
      final second = await chatService.getOrCreateConversation('uid1', 'uid2');

      expect(first, second);
    });

    test('sendMessage adds document and updates conversation', () async {
      final convoId =
          await chatService.getOrCreateConversation('uid1', 'uid2');

      await chatService.sendMessage(
        conversationId: convoId,
        senderId: 'uid1',
        text: 'Hello!',
      );

      final messages = await fakeFirestore
          .collection('conversations')
          .doc(convoId)
          .collection('messages')
          .get();
      expect(messages.docs, hasLength(1));
      expect(messages.docs.first.data()['text'], 'Hello!');
      expect(messages.docs.first.data()['senderId'], 'uid1');

      final convo =
          await fakeFirestore.collection('conversations').doc(convoId).get();
      expect(convo.data()!['lastMessage'], 'Hello!');
    });

    test('getUser returns user model', () async {
      await fakeFirestore.collection('users').doc('uid1').set({
        'uid': 'uid1',
        'name': 'Test User',
        'email': 'test@test.com',
        'photoUrl': '',
      });

      final user = await chatService.getUser('uid1');

      expect(user, isNotNull);
      expect(user!.name, 'Test User');
    });

    test('getUser returns null for non-existent user', () async {
      final user = await chatService.getUser('nonexistent');
      expect(user, isNull);
    });

    test('getConversations streams conversations for user', () async {
      await fakeFirestore.collection('conversations').add({
        'members': ['uid1', 'uid2'],
        'lastMessage': 'Hi',
        'updatedAt': DateTime.now(),
      });
      await fakeFirestore.collection('conversations').add({
        'members': ['uid3', 'uid4'],
        'lastMessage': 'Bye',
        'updatedAt': DateTime.now(),
      });

      final convos =
          await chatService.getConversations('uid1').first;

      expect(convos, hasLength(1));
      expect(convos.first.members, contains('uid1'));
    });
  });
}
