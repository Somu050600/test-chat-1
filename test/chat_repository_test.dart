import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_1/core/services/chat_repository.dart';

void main() {
  test('conversationIdForPair is stable regardless of argument order', () {
    expect(
      ChatRepository.conversationIdForPair('b', 'a'),
      ChatRepository.conversationIdForPair('a', 'b'),
    );
    expect(
      ChatRepository.conversationIdForPair('a', 'b'),
      'a_b',
    );
  });
}
