import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../services/api_client.dart';
import '../widgets/app_chrome.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if ([firstName, lastName, email, password].any((value) => value.isEmpty)) {
      showAppMessage(context, 'Completa todos los campos.');
      return;
    }

    if (password.length < 8) {
      showAppMessage(context, 'La contrasena debe tener minimo 8 caracteres.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      await ApiClient.instance.login(email, password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.userType,
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Crea tu cuenta',
      subtitle: 'El registro se guarda en el backend de Railway.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(label: 'Nombre', controller: _firstNameController),
          const SizedBox(height: 18),
          AppTextField(label: 'Apellido', controller: _lastNameController),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Correo',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Contrasena',
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Registrarme',
            loading: _loading,
            onPressed: _register,
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Ya tengo cuenta',
            outline: true,
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.signIn,
            ),
          ),
        ],
      ),
    );
  }
}
