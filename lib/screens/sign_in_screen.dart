import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_routes.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showAppMessage(context, 'Ingresa correo y contrasena.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.login(email, password);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.profile,
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
      title: 'Bienvenido a BiceSmartIoT',
      subtitle: 'Conectado al backend: ${ApiConfig.baseUrl}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: ApiClient.instance.health(),
            builder: (context, snapshot) {
              final online =
                  snapshot.hasData && snapshot.data?['status'] == 'UP';
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: online
                      ? AppColors.limeGreen.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: online ? AppColors.limeGreen : Colors.orange,
                  ),
                ),
                child: Text(
                  online
                      ? 'Backend activo'
                      : 'Verificando backend. Si falla, revisa internet o Railway.',
                  style: TextStyle(
                    color: online ? AppColors.limeGreen : Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Correo',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              labelText: 'Contrasena',
              labelStyle: const TextStyle(color: AppColors.textMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.35),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.limeGreen,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.white,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                showAppMessage(
                  context,
                  'El backend aun no expone recuperacion de contrasena.',
                );
              },
              child: const Text(
                'Olvide mi contrasena',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Iniciar sesion',
            loading: _loading,
            onPressed: _login,
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Crear cuenta',
            outline: true,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
          ),
          const SizedBox(height: 18),
          const Text(
            'Usuario admin de prueba si la base esta vacia: admin@bikelab.io / Admin#123',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
