import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:test_chat_1/core/constants/app_strings.dart';
import 'package:test_chat_1/main.dart';

void main() {
  testWidgets('home shows architecture subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Architecture ready'), findsOneWidget);
    expect(find.text(AppStrings.appTitle), findsWidgets);
  });
}
