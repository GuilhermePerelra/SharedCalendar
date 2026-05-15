import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _errorMessage;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _loading = false;
      if (response.session != null) {
        notifyListeners();
        return true;
      }
      _errorMessage =
          'Verifique a sua senha e nome de usuário e tente novamente';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage =
          'Verifique a sua senha e nome de usuário e tente novamente';
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
