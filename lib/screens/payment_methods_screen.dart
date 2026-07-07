import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _tokenController = TextEditingController(text: 'tok_test_4242');
  final _brandController = TextEditingController(text: 'VISA');
  final _last4Controller = TextEditingController(text: '4242');
  late Future<List<PaymentMethodResource>> _future;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.paymentMethods();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _brandController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _future = ApiClient.instance.paymentMethods());
  }

  Future<void> _save() async {
    if (_last4Controller.text.trim().length != 4) {
      showAppMessage(context, 'El campo last4 debe tener 4 digitos.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.addPaymentMethod(
        tokenRef: _tokenController.text,
        brand: _brandController.text,
        last4: _last4Controller.text,
        makeDefault: true,
      );
      if (!mounted) return;
      showAppMessage(context, 'Metodo de pago guardado.');
      _refresh();
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
      title: 'Metodos de pago',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const AppCard(
            child: Text(
              'Este endpoint requiere ROLE_CUSTOMER. Las tarjetas aqui usan token de prueba, no datos reales.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(label: 'Token', controller: _tokenController),
          const SizedBox(height: 18),
          AppTextField(label: 'Marca', controller: _brandController),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Ultimos 4 digitos',
            controller: _last4Controller,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Guardar metodo',
            loading: _loading,
            onPressed: _save,
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<PaymentMethodResource>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingPanel('Cargando metodos...');
              }
              if (snapshot.hasError) {
                return ErrorPanel(
                  message: snapshot.error.toString(),
                  onRetry: _refresh,
                );
              }

              final methods = snapshot.data ?? const [];
              if (methods.isEmpty) {
                return const AppCard(
                  child: Text(
                    'No hay metodos registrados.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }

              return Column(
                children: methods
                    .map(
                      (method) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.credit_card,
                              color: AppColors.limeGreen,
                            ),
                            title: Text(
                              method.brand,
                              style: const TextStyle(color: AppColors.white),
                            ),
                            subtitle: Text(
                              '**** ${method.last4}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                            trailing: method.isDefault
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.limeGreen,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
