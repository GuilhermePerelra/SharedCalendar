import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/cadastro_view_model.dart';
import 'login_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  static const double _fieldSpacing = 16.0;
  static const double _bottomSpacing = 24.0;
  static const int _minUsernameLength = 3;
  static const int _maxUsernameLength = 20;
  static const int _minPasswordLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome de usuário é obrigatório';
    }
    if (value.length < _minUsernameLength) {
      return 'Nome de usuário deve ter pelo menos $_minUsernameLength caracteres';
    }
    if (value.length > _maxUsernameLength) {
      return 'Nome de usuário deve ter no máximo $_maxUsernameLength caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Nome de usuário deve conter apenas letras, números e _';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < _minPasswordLength) {
      return 'Senha deve ter pelo menos $_minPasswordLength caracteres';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != _passwordController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: _buildInputDecoration('Nome de usuário'),
      validator: _validateUsername,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _buildInputDecoration('Email'),
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: _buildInputDecoration('Senha'),
      obscureText: true,
      validator: _validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: _buildInputDecoration('Confirmar Senha'),
      obscureText: true,
      validator: _validateConfirmPassword,
    );
  }

  Widget _buildErrorMessage(String? message) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: _bottomSpacing),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubmitButton(CadastroViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.loading ? null : _cadastro,
        child: viewModel.loading
            ? const CircularProgressIndicator()
            : const Text('Cadastrar'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context); 
      },
      child: const Text('Já tem conta? Faça login'),
    );
  }

  Future<void> _cadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<CadastroViewModel>();
    await viewModel.cadastro(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _usernameController.text.trim(),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Consumer<CadastroViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      _buildUsernameField(),
                      const SizedBox(height: _fieldSpacing),
                      _buildEmailField(),
                      const SizedBox(height: _fieldSpacing),
                      _buildPasswordField(),
                      const SizedBox(height: _fieldSpacing),
                      _buildConfirmPasswordField(),
                      _buildErrorMessage(viewModel.errorMessage),
                      const SizedBox(height: _fieldSpacing),
                      _buildSubmitButton(viewModel),
                      const SizedBox(height: _fieldSpacing),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
