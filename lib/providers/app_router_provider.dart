import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_router.dart';
import 'service_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = ref.watch(authRefreshListenableProvider);
  final router = createAppRouter(auth, refresh);
  ref.onDispose(router.dispose);
  return router;
});
