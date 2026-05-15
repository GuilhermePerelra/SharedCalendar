import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mvvm/login_view_model.dart';
import 'cadastro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _fieldSpacing = 16.0;
  static const double _bottomSpacing = 24.0;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final viewModel = context.read<LoginViewModel>();
    await viewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _buildInputDecoration('Email'),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: _buildInputDecoration('Senha'),
      obscureText: true,
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

  Widget _buildSubmitButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.loading ? null : _login,
        child: viewModel.loading
            ? const CircularProgressIndicator()
            : const Text('Entrar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildEmailField(),
                    const SizedBox(height: _fieldSpacing),
                    _buildPasswordField(),
                    _buildErrorMessage(viewModel.errorMessage),
                    const SizedBox(height: _fieldSpacing),
                    _buildSubmitButton(viewModel),
                    const SizedBox(height: _fieldSpacing),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CadastroPage(),
                          ),
                        );
                      },
                      child: const Text('Não tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
