import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../models/api_models.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  late Future<_ProfileData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProfileData> _load() async {
    final api = ApiClient.instance;
    AppUser? user = api.currentUser;
    MetricsResource metrics = const MetricsResource(
      usersTotal: 0,
      providersApproved: 0,
      vehiclesAvailable: 0,
      vehiclesInService: 0,
      bookingsConfirmed: 0,
      bookingsActive: 0,
      bookingsFinished: 0,
      paymentsAuthorized: 0,
      paymentsCaptured: 0,
    );
    List<AppUser> users = const [];
    ProviderResource? provider;

    if (api.isAuthenticated) {
      try {
        user = await api.me();
      } on ApiException {
        user = api.currentUser;
      }
    }

    try {
      metrics = await api.metrics();
    } on ApiException {
      // El perfil debe seguir funcionando aunque las metricas fallen.
    }

    if (user?.isAdmin == true) {
      try {
        users = await api.adminUsers();
      } on ApiException {
        users = const [];
      }
    }

    if (user?.isProvider == true) {
      try {
        provider = await api.myProvider();
      } on ApiException {
        provider = null;
      }
    }

    return _ProfileData(
      user: user,
      metrics: metrics,
      adminUsers: users,
      provider: provider,
    );
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Mi perfil',
      child: FutureBuilder<_ProfileData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingPanel('Cargando perfil...');
          }
          if (snapshot.hasError) {
            return ErrorPanel(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;
          final user = data.user;

          return RefreshIndicator(
            color: AppColors.limeGreen,
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.limeGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.black,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.fullName ?? 'Sin sesion',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ??
                                      'Inicia sesion para ver tus datos.',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _InfoRow(
                        label: 'Roles',
                        value: user?.roles.join(', ') ?? 'No autenticado',
                      ),
                      if (data.provider != null) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Proveedor',
                          value:
                              '${data.provider!.displayName} (${data.provider!.status})',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Vehiculos',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.vehicles,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Proveedor',
                        outline: true,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.providerRegistration,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _MetricsGrid(metrics: data.metrics),
                if (data.adminUsers.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _UsersPanel(users: data.adminUsers),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final MetricsResource metrics;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Usuarios', metrics.usersTotal),
      ('Proveedores', metrics.providersApproved),
      ('Vehiculos', metrics.vehiclesAvailable),
      ('Reservas activas', metrics.bookingsActive),
      ('Pagos capturados', metrics.paymentsCaptured),
      ('En servicio', metrics.vehiclesInService),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.$2.toString(),
                style: const TextStyle(
                  color: AppColors.limeGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.$1,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UsersPanel extends StatelessWidget {
  const _UsersPanel({required this.users});

  final List<AppUser> users;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Usuarios del backend',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...users.take(8).map(
                (user) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.account_circle,
                    color: AppColors.limeGreen,
                  ),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(color: AppColors.white),
                  ),
                  subtitle: Text(
                    '${user.email} - ${user.roles.join(', ')}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileData {
  const _ProfileData({
    required this.user,
    required this.metrics,
    required this.adminUsers,
    required this.provider,
  });

  final AppUser? user;
  final MetricsResource metrics;
  final List<AppUser> adminUsers;
  final ProviderResource? provider;
}
