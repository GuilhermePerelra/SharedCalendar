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
      if (response.session != null) {
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Falha no cadastro';
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
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