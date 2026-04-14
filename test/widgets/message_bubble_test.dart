import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/chat/widgets/message_bubble.dart';
import 'package:chat_app/models/message_model.dart';

void main() {
  final testTime = DateTime(2024, 1, 1, 12, 30);

  MessageModel buildMsg({MessageStatus status = MessageStatus.sent, String text = 'Test message'}) {
    return MessageModel(
      id: 'msg1',
      senderId: 'uid1',
      text: text,
      createdAt: testTime,
      clientTimestamp: testTime,
      status: status,
    );
  }

  group('MessageBubble', () {
    Widget buildWidget({required bool isMe, MessageStatus status = MessageStatus.sent}) {
      return MaterialApp(
        home: Scaffold(
          body: MessageBubble(message: buildMsg(status: status), isMe: isMe),
        ),
      );
    }

    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true));
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('shows time', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true));
      expect(find.text('12:30'), findsOneWidget);
    });

    testWidgets('shows single check for sent', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true));
      expect(find.byIcon(Icons.done), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('does not show check icon for received messages', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: false));
      expect(find.byIcon(Icons.done), findsNothing);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('shows double check gray for delivered', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true, status: MessageStatus.delivered));
      expect(find.byIcon(Icons.done_all), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.done_all));
      expect(icon.color, isNot(Colors.blue.shade200));
    });

    testWidgets('shows double check blue for read', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true, status: MessageStatus.read));
      expect(find.byIcon(Icons.done_all), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.done_all));
      expect(icon.color, Colors.blue.shade200);
    });
  });
}
