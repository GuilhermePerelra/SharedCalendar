import 'package:sharedcalendar/exceptions/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseErrorHandler {
  static AppException parse(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return AppException('E-mail ou senha inválidos.');

        case 'email not confirmed':
          return AppException(
            'Seu e-mail ainda não foi confirmado.',
          );

        case 'user already registered':
          return AppException(
            'Já existe uma conta cadastrada com este e-mail.',
          );

        default:
          return AppException(
            'Falha na autenticação. Tente novamente.',
          );
      }
    }

    if (error is PostgrestException) {
      final code = error.code;

      switch (code) {
        case '23505':
          return AppException(
            'Este registro já existe.',
          );

        case '23503':
          return AppException(
            'Operação não permitida devido a dependências existentes.',
          );

        case '42501':
          return AppException(
            'Você não possui permissão para realizar esta ação.',
          );

        case 'PGRST116':
          return AppException(
            'Registro não encontrado.',
          );

        default:
          return AppException(
            'Erro ao processar solicitação.',
          );
      }
    }

    return AppException(
      'Ocorreu um erro inesperado. Tente novamente.',
    );
  }
}