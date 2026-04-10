import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Placeholder; real-time messages in Step 5.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${AppStrings.chatPlaceholder} ($conversationId)')),
      body: Center(
        child: Text('Conversation: $conversationId'),
      ),
    );
  }
}
