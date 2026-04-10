import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../routes/app_router.dart';
import 'conversations_tab.dart';
import 'user_search_delegate.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Search users',
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: UserSearchDelegate(ref),
            ),
          ),
          if (currentUser?.photoUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _showProfileMenu(context, ref),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(currentUser!.photoUrl!),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Account',
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => _showProfileMenu(context, ref),
            ),
        ],
      ),
      body: const ConversationsTab(),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider).valueOrNull;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (_) => _ProfileSheet(
        name: user?.name ?? '',
        email: user?.email ?? '',
        photoUrl: user?.photoUrl,
        onSignOut: () async {
          Navigator.pop(context);
          await ref.read(authServiceProvider).signOut();
          if (context.mounted) context.go(loginRoute);
        },
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final VoidCallback onSignOut;

  const _ProfileSheet({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage:
                photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? const Icon(Icons.person, size: 36)
                : null,
          ),
          const SizedBox(height: 12),
          Text(name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          Text(email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
