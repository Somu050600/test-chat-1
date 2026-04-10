import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/service_providers.dart';

/// Ensures `users/{uid}` exists/updates whenever auth state resolves to a user.
class UserProfileListener extends ConsumerWidget {
  const UserProfileListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
      next.whenData((user) {
        if (user != null) {
          ref.read(userRepositoryProvider).upsertCurrentUser(user);
        }
      });
    });

    return child;
  }
}
