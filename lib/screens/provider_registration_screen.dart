import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _docNumberController = TextEditingController();
  String _docType = 'DNI';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ApiClient.instance.currentUser;
    if (user != null) {
      _displayNameController.text = user.fullName;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_displayNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _docNumberController.text.trim().isEmpty) {
      showAppMessage(context, 'Completa todos los datos de proveedor.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.onboardProviderRole();
      final provider = await ApiClient.instance.requestProviderOnboarding(
        displayName: _displayNameController.text,
        phone: _phoneController.text,
        docType: _docType,
        docNumber: _docNumberController.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: const Text(
            'Solicitud enviada',
            style: TextStyle(color: AppColors.white),
          ),
          content: Text(
            'Estado actual: ${provider.status}. Para crear vehiculos el backend exige proveedor aprobado.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.addVehicle);
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Registro de proveedor',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const AppCard(
            child: Text(
              'Estos datos se enviaran al backend. Un admin debe aprobar al proveedor antes de poder publicar vehiculos.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Nombre comercial',
            controller: _displayNameController,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Celular',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _docType,
            dropdownColor: AppColors.cardSurface,
            decoration: InputDecoration(
              labelText: 'Tipo de documento',
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
            ),
            style: const TextStyle(color: AppColors.white),
            items: const [
              DropdownMenuItem(value: 'DNI', child: Text('DNI')),
              DropdownMenuItem(value: 'RUC', child: Text('RUC')),
              DropdownMenuItem(value: 'CE', child: Text('CE')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _docType = value);
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Numero de documento',
            controller: _docNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Enviar solicitud',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
