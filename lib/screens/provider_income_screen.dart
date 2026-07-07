import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class ProviderIncomeScreen extends StatefulWidget {
  const ProviderIncomeScreen({super.key});

  @override
  State<ProviderIncomeScreen> createState() => _ProviderIncomeScreenState();
}

class _ProviderIncomeScreenState extends State<ProviderIncomeScreen> {
  late Future<_IncomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_IncomeData> _load() async {
    final metrics = await ApiClient.instance.metrics();
    List<PayoutResource> payouts = const [];
    if (ApiClient.instance.currentUser?.isProvider == true) {
      payouts = await ApiClient.instance.payouts();
    }
    return _IncomeData(metrics: metrics, payouts: payouts);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Ingresos',
      child: FutureBuilder<_IncomeData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingPanel('Cargando ingresos...');
          }
          if (snapshot.hasError) {
            return ErrorPanel(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final totalPayouts = data.payouts.fold<double>(
            0,
            (sum, payout) => sum + payout.amount,
          );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen operativo',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _MetricLine(
                      label: 'Reservas confirmadas',
                      value: data.metrics.bookingsConfirmed.toString(),
                    ),
                    _MetricLine(
                      label: 'Reservas activas',
                      value: data.metrics.bookingsActive.toString(),
                    ),
                    _MetricLine(
                      label: 'Reservas finalizadas',
                      value: data.metrics.bookingsFinished.toString(),
                    ),
                    _MetricLine(
                      label: 'Pagos capturados',
                      value: data.metrics.paymentsCaptured.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payouts del proveedor',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total: S/ ${totalPayouts.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.limeGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (data.payouts.isEmpty)
                      const Text(
                        'No hay payouts registrados o el usuario no tiene ROLE_PROVIDER.',
                        style: TextStyle(color: AppColors.textMuted),
                      )
                    else
                      ...data.payouts.map(
                        (payout) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'S/ ${payout.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.white),
                          ),
                          subtitle: Text(
                            payout.status,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Retirar ganancias',
                onPressed: () {
                  showAppMessage(
                    context,
                    'El backend aun no expone un endpoint para solicitar retiro.',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeData {
  const _IncomeData({
    required this.metrics,
    required this.payouts,
  });

  final MetricsResource metrics;
  final List<PayoutResource> payouts;
}
