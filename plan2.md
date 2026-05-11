# Plano: AuthGuard com GoRouter

## Contexto
App de calendário compartilhado em Flutter com Supabase.
Controle de rotas baseado em autenticação: usuário não autenticado vai para login, autenticado vai para dashboard.
Remover qualquer redirect manual para dashboard que já exista no código.

## Dependência
Adicionar no `pubspec.yaml`:
```yaml
dependencies:
  go_router: ^14.0.0
```

Rodar:
```bash
flutter pub get
```

## Estrutura de arquivos a criar/modificar
lib/
config/
router.dart       # novo - configuração do GoRouter com AuthGuard
main.dart           # modificar - usar o router
pages/
login_page.dart   # já existe - não mexer
cadastro_page.dart # já existe - não mexer
dashboard_page.dart # já existe - não mexer

## Código

### config/router.dart (novo)
```dart
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../pages/login_page.dart';
import '../pages/cadastro_page.dart';
import '../pages/dashboard_page.dart';

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
      builder: (context, state) => const DashboardPage(),
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
```

### main.dart (modificar)
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'config/router.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Calendário Compartilhado',
      routerConfig: router,
    );
  }
}
```

### login_page.dart (remover redirect manual)
Remover qualquer código parecido com isso:
```dart
// ❌ Remover
Navigator.pushReplacementNamed(context, '/dashboard');
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage()));
context.go('/dashboard');
```
O GoRouter já cuida do redirect automaticamente quando a sessão muda.

### cadastro_page.dart (remover redirect manual)
Remover qualquer código parecido com isso:
```dart
// ❌ Remover
if (authResponse.session != null) {
  Navigator.pushReplacementNamed(context, '/home');
  context.go('/dashboard');
}
```
O GoRouter já detecta que o usuário está autenticado via `refreshListenable` e redireciona sozinho.

## Como funciona
1. App inicia → GoRouter verifica `auth.currentUser`
2. Se nulo → redireciona para `/` (login)
3. Se autenticado → redireciona para `/dashboard`
4. Qualquer mudança no estado de autenticação (login, cadastro, logout) → `GoRouterRefreshStream` notifica o GoRouter → redirect é avaliado novamente automaticamente
5. Logout → `auth.currentUser` vira nulo → GoRouter manda para login automaticamente

## Fluxo completo
- Abre o app sem sessão → Login
- Faz login ou cadastro → Dashboard (automático, sem redirect manual)
- Faz logout → Login (automático)
- Tenta acessar `/dashboard` sem estar autenticado → Login (automático)