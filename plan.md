 Plano: Autenticação automática após cadastro

## Contexto
App de calendário compartilhado em Flutter com Supabase.
Após o cadastro, o usuário deve ser autenticado automaticamente sem precisar fazer login separado.

## Banco de dados

### Estrutura atual
```sql
CREATE TABLE public.users (
  id uuid NOT NULL,
  username character varying,
  login text NOT NULL UNIQUE,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

CREATE TABLE public.events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  title character varying NOT NULL,
  target_date timestamp with time zone NOT NULL,
  description text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  created_by uuid NOT NULL,
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT fk_events_created_by FOREIGN KEY (created_by) REFERENCES public.users(id)
);

CREATE TABLE public.event_share (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  user_id uuid NOT NULL,
  CONSTRAINT event_share_pkey PRIMARY KEY (id),
  CONSTRAINT fk_event_share_event FOREIGN KEY (event_id) REFERENCES public.events(id),
  CONSTRAINT fk_event_share_user FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

### Scripts a rodar no Supabase SQL Editor

**1. Trigger para criar usuário em public.users automaticamente:**
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, login, username)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'username');
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**2. Policies de segurança (RLS):**
```sql
CREATE POLICY "Usuários autenticados podem buscar outros"
ON public.users FOR SELECT
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Usuário atualiza apenas seus dados"
ON public.users FOR UPDATE
USING (auth.uid() = id);

CREATE POLICY "Usuário vê seus eventos"
ON public.events FOR SELECT
USING (
  auth.uid() = created_by OR
  EXISTS (
    SELECT 1 FROM public.event_share
    WHERE event_share.event_id = id
    AND event_share.user_id = auth.uid()
  )
);

CREATE POLICY "Usuário cria seus próprios eventos"
ON public.events FOR INSERT
WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Usuário atualiza seus próprios eventos"
ON public.events FOR UPDATE
USING (auth.uid() = created_by);

CREATE POLICY "Usuário deleta seus próprios eventos"
ON public.events FOR DELETE
USING (auth.uid() = created_by);

CREATE POLICY "Usuário vê compartilhamentos"
ON public.event_share FOR SELECT
USING (
  auth.uid() = user_id OR
  EXISTS (
    SELECT 1 FROM public.events
    WHERE events.id = event_id
    AND events.created_by = auth.uid()
  )
);

CREATE POLICY "Dono do evento pode compartilhar"
ON public.event_share FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.events
    WHERE events.id = event_id
    AND events.created_by = auth.uid()
  )
);

CREATE POLICY "Dono do evento pode remover compartilhamento"
ON public.event_share FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.events
    WHERE events.id = event_id
    AND events.created_by = auth.uid()
  )
);
```

## Configuração do Supabase
Em **Authentication → Providers → Email**, desmarcar **"Confirm email"** para que o usuário seja autenticado imediatamente após o cadastro sem precisar confirmar o email.

## Código Flutter

### env/environment.dart
```dart
const String supabaseUrl = 'https://qmprymrrtcnbrxectmhj.supabase.co';
const String supabaseAnonKey = 'SUA_ANON_KEY_AQUI';
```

### services/auth_service.dart
O método `cadastro` deve:
1. Verificar se o username já existe
2. Chamar `signUp` passando o username no metadata
3. O Supabase retorna a sessão autenticada automaticamente (com "Confirm email" desativado)
4. O trigger cuida de inserir em `public.users`
5. Redirecionar para a tela principal sem precisar fazer login separado

```dart
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../env/environment.dart';

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  static Future initialize() async {
    await supabase.Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  Future login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future cadastro(
    String email,
    String password,
    String username,
  ) async {
    final existingUser = await _supabase
        .from('users')
        .select('username')
        .eq('username', username)
        .maybeSingle();

    if (existingUser != null) {
      throw Exception('Nome de usuário já está em uso');
    }

    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future logout() async {
    await _supabase.auth.signOut();
  }

  supabase.User? get currentUser => _supabase.auth.currentUser;

  Stream get authStateChanges =>
      _supabase.auth.onAuthStateChange;
}
```

### Navegação após cadastro
Na tela de cadastro, após chamar `cadastro()`, verificar se `authResponse.session != null` para confirmar que o usuário já está autenticado e redirecionar para a tela principal:

```dart
final authResponse = await authService.cadastro(email, password, username);

if (authResponse.session != null) {
  // Usuário autenticado, redirecionar para tela principal
  Navigator.pushReplacementNamed(context, '/home');
} else {
  // Confirmação de email ainda pendente (não deve acontecer com "Confirm email" desativado)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Verifique seu email para confirmar o cadastro')),
  );
}
```

## Fluxo completo
1. Usuário preenche email, senha e username
2. App verifica se username já existe
3. `signUp` cria o usuário no `auth.users` com username no metadata
4. Trigger insere automaticamente em `public.users`
5. Supabase retorna sessão autenticada direto
6. App redireciona para tela principal