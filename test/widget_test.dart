import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_chat_1/main.dart';

void main() {
  testWidgets('home shows setup message', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatApp()));

    expect(find.textContaining('Firebase initialized'), findsOneWidget);
  });
}
