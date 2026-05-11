import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../pages/login_page.dart';
import '../pages/cadastro_page.dart';
import '../pages/home_page.dart';

final router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    supabase.Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) {
    final logado = supabase.Supabase.instance.client.auth.currentUser != null;
    final naLoginOuCadastro =
        state.matchedLocation == '/' ||
        state.matchedLocation == '/cadastro';

    if (!logado && !naLoginOuCadastro) return '/';
    if (logado && naLoginOuCadastro) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const CadastroPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

// Necessário para o GoRouter reagir a mudanças de autenticação
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}