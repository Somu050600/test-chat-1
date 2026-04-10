import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/chat/widgets/message_bubble.dart';
import 'package:chat_app/models/message_model.dart';

void main() {
  group('MessageBubble', () {
    Widget buildWidget({required bool isMe, String text = 'Test message'}) {
      return MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: MessageModel(
              id: 'msg1',
              senderId: 'uid1',
              text: text,
              createdAt: DateTime(2024, 1, 1, 12, 30),
              status: MessageStatus.sent,
            ),
            isMe: isMe,
          ),
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

    testWidgets('shows check icon for sent messages from me', (tester) async {
      await tester.pumpWidget(buildWidget(isMe: true));
      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('does not show check icon for received messages',
        (tester) async {
      await tester.pumpWidget(buildWidget(isMe: false));
      expect(find.byIcon(Icons.done), findsNothing);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('renders read status with done_all icon', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: MessageModel(
              id: 'msg1',
              senderId: 'uid1',
              text: 'Read msg',
              createdAt: DateTime(2024, 1, 1, 12, 30),
              status: MessageStatus.read,
            ),
            isMe: true,
          ),
        ),
      ));
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });
  });
}
