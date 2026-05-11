# 📅 Calendário Compartilhado

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)

Um aplicativo Flutter para criação e compartilhamento de eventos de calendário de forma colaborativa. Permita que usuários criem eventos pessoais e os compartilhem com outros usuários de maneira simples e intuitiva.

## ✨ Funcionalidades

- 🔐 **Autenticação Segura**: Login e cadastro de usuários com Supabase Auth
- 📝 **Criação de Eventos**: Adicione eventos com título, data, descrição e muito mais
- 👥 **Compartilhamento**: Compartilhe eventos com outros usuários
- 📱 **Interface Intuitiva**: Design limpo e responsivo para múltiplas plataformas
- 🔄 **Sincronização em Tempo Real**: Dados sincronizados via Supabase

## 🛠️ Tecnologias Utilizadas

- **Frontend**: Flutter
- **Backend**: Supabase (Database + Auth)
- **State Management**: Provider
- **Roteamento**: Go Router
- **Linguagem**: Dart

## 🚀 Instalação

### Pré-requisitos

- Flutter SDK (versão 3.11.5 ou superior)
- Conta no [Supabase](https://supabase.com/) para configurar o backend

### Passos

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/seu-usuario/sharedcalendar.git
   cd sharedcalendar
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Configure o Supabase**:
   - Crie um projeto no Supabase
   - Copie a URL e a chave anônima
   - Atualize o arquivo `lib/env/environment.dart` com suas credenciais:
     ```dart
     const String supabaseUrl = 'SUA_URL_AQUI';
     const String supabaseAnonKey = 'SUA_CHAVE_ANONIMA_AQUI';
     ```

4. **Configure o banco de dados**:
   - Execute os scripts SQL no painel do Supabase para criar as tabelas `users`, `events` e `event_shares`

5. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

## 📱 Como Usar

1. **Cadastro/Login**: Crie uma conta ou faça login
2. **Criar Evento**: Na tela principal, adicione novos eventos
3. **Compartilhar**: Selecione usuários para compartilhar seus eventos
4. **Visualizar**: Veja todos os eventos compartilhados em seu calendário

## 🏗️ Arquitetura

O projeto segue o padrão MVVM (Model-View-ViewModel):

- **Models**: Representam os dados (Event, User, EventShare)
- **ViewModels**: Gerenciam o estado e lógica de apresentação
- **Views/Pages**: Interfaces do usuário
- **Services**: Comunicação com o backend Supabase

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para:

- Reportar bugs
- Sugerir novas funcionalidades
- Enviar pull requests

## 📄 Licença

Este projeto é privado e não possui licença pública.

## 📞 Contato

Para dúvidas ou sugestões, entre em contato com a equipe de desenvolvimento.

---

*Desenvolvido com ❤️ usando Flutter e Supabase*
