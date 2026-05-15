import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CadastroViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _errorMessage;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<bool> cadastro(String email, String password, String username) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.cadastro(email, password, username);
      _loading = false;
      if (response.session != null) {
        notifyListeners();
        return true;
      }
      _errorMessage = 'Falha ao criar a conta. Tente novamente';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Falha ao criar a conta. Tente novamente';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
