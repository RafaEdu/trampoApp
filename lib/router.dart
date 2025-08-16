import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:freelago/screens/login_screen.dart';
import 'package:freelago/screens/user_type_selection_screen.dart';
import 'package:freelago/screens/signup_screen.dart';
import 'package:freelago/screens/home_screen.dart';
import 'package:freelago/screens/chat_screen.dart';
import 'package:freelago/screens/perfil_screen.dart';
import 'package:freelago/screens/settings_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/login',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute =
        [
          '/login',
          '/select-user-type',
        ].any((p) => state.matchedLocation.startsWith(p)) ||
        state.matchedLocation.startsWith('/signup');

    if (!loggedIn && !isAuthRoute) return '/login';
    if (loggedIn && isAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/select-user-type',
      builder: (_, __) => const UserTypeSelectionScreen(),
    ),
    GoRoute(
      path: '/signup/:type', // type = pf | pj_empresa | pj_individual
      builder: (context, state) =>
          SignUpScreen(type: state.pathParameters['type']!),
    ),
    GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
    GoRoute(
      path: '/chat/:receiverID',
      builder: (context, state) =>
          ChatScreen(receiverID: state.pathParameters['receiverID']!),
    ),
    GoRoute(path: '/perfil', builder: (_, __) => const PerfilScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
