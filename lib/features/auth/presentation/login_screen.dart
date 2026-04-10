import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Placeholder UI; [AuthService] wires in Step 3.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loginPlaceholder)),
      body: const Center(
        child: Text('Google sign-in will be implemented in Step 3.'),
      ),
    );
  }
}
