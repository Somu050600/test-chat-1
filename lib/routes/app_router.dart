import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/chat/presentation/chat_screen.dart';

const String loginRoute = '/login';
const String homeRoute = '/';
const String chatRoute = '/chat/:conversationId';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: homeRoute,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginPage = state.matchedLocation == loginRoute;

      if (!isLoggedIn && !isLoginPage) return loginRoute;
      if (isLoggedIn && isLoginPage) return homeRoute;
      return null;
    },
    routes: [
      GoRoute(
        path: loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: chatRoute,
        builder: (context, state) {
          final conversationId =
              state.pathParameters['conversationId']!;
          final otherUserName =
              state.uri.queryParameters['name'] ?? 'Chat';
          final otherUserPhoto =
              state.uri.queryParameters['photo'];
          final otherUserId =
              state.uri.queryParameters['uid'] ?? '';
          return ChatScreen(
            conversationId: conversationId,
            otherUserName: otherUserName,
            otherUserPhotoUrl: otherUserPhoto,
            otherUserId: otherUserId,
          );
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
