import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:freelago/screens/login_screen.dart';
import 'package:freelago/screens/user_type_selection_screen.dart';
import 'package:freelago/screens/pf_subtype_selection_screen.dart';
import 'package:freelago/screens/pj_subtype_selection_screen.dart';
import 'package:freelago/screens/signup_screen.dart';
import 'package:freelago/screens/home_screen.dart';
import 'package:freelago/screens/chat_screen.dart';
import 'package:freelago/screens/perfil_screen.dart';
import 'package:freelago/screens/edit_perfil_screen.dart'; // NOVO IMPORT
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
          '/select-user-type/pf',
          '/select-user-type/pj',
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
      path: '/select-user-type/pf',
      builder: (_, __) => const PfSubtypeSelectionScreen(),
    ),
    GoRoute(
      path: '/select-user-type/pj',
      builder: (_, __) => const PjSubtypeSelectionScreen(),
    ),
    GoRoute(
      path: '/signup/:type',
      builder: (context, state) =>
          SignUpScreen(type: state.pathParameters['type']!),
    ),
    GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
    GoRoute(
      path: '/chat/:receiverID',
      builder: (context, state) =>
          ChatScreen(receiverID: state.pathParameters['receiverID']!),
    ),
    // ALTERAÇÕES NAS ROTAS DE PERFIL
    GoRoute(
      path: '/perfil',
      builder: (_, __) => const PerfilScreen(),
      routes: [
        GoRoute(
          path: 'edit', // Rota aninhada: /perfil/edit
          builder: (_, __) => const EditPerfilScreen(),
        ),
      ],
    ),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
