import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/chat/widgets/message_input.dart';

void main() {
  group('MessageInput', () {
    testWidgets('renders text field and send button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(onSend: (_) async {}),
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('calls onSend with text when send pressed', (tester) async {
      String? sentText;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(onSend: (text) async {
            sentText = text;
          }),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(sentText, 'Hello');
    });

    testWidgets('does not send empty text', (tester) async {
      bool wasCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(onSend: (_) async {
            wasCalled = true;
          }),
        ),
      ));

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(wasCalled, isFalse);
    });

    testWidgets('clears input after send', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MessageInput(onSend: (_) async {}),
        ),
      ));

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });
}
