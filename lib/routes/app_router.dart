import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/chat/presentation/conversation_list_screen.dart';
import '../features/chat/presentation/user_list_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(
  FirebaseAuth auth,
  Listenable refreshListenable,
) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutePaths.home,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final user = auth.currentUser;
      final loc = state.matchedLocation;

      if (user == null) {
        if (loc.startsWith('/chat/') || loc == AppRoutePaths.people) {
          final next = state.uri.toString();
          return '${AppRoutePaths.login}?next=${Uri.encodeComponent(next)}';
        }
        return null;
      }

      if (loc == AppRoutePaths.login) {
        return AppRoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.home,
        name: AppRouteNames.home,
        builder: (context, state) => const ConversationListScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) {
          final next = state.uri.queryParameters['next'];
          return LoginScreen(redirectPath: next);
        },
      ),
      GoRoute(
        path: AppRoutePaths.people,
        name: AppRouteNames.people,
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.chatPattern,
        name: AppRouteNames.chat,
        builder: (context, state) {
          final id = state.pathParameters['conversationId'] ?? '';
          return ChatScreen(conversationId: id);
        },
      ),
    ],
  );
}

abstract final class AppRoutePaths {
  static const home = '/';
  static const login = '/login';
  static const people = '/people';
  static const chatPattern = '/chat/:conversationId';

  static String chat(String conversationId) => '/chat/$conversationId';
}

abstract final class AppRouteNames {
  static const home = 'home';
  static const login = 'login';
  static const people = 'people';
  static const chat = 'chat';
}
