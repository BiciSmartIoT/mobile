import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<_NotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_NotificationItem>> _load() async {
    final metrics = await ApiClient.instance.metrics();
    final user = ApiClient.instance.currentUser;
    return [
      _NotificationItem(
        title: 'Backend conectado',
        message:
            'BiceSmartIoT esta leyendo metricas desde Railway. Usuarios: ${metrics.usersTotal}.',
        icon: Icons.cloud_done,
      ),
      if (user != null)
        _NotificationItem(
          title: 'Sesion activa',
          message: '${user.fullName} - ${user.roles.join(', ')}',
          icon: Icons.verified_user,
        ),
      _NotificationItem(
        title: 'Vehiculos disponibles',
        message:
            '${metrics.vehiclesAvailable} disponibles y ${metrics.vehiclesInService} en servicio.',
        icon: Icons.directions_bike,
      ),
      _NotificationItem(
        title: 'Reservas',
        message:
            '${metrics.bookingsActive} activas, ${metrics.bookingsConfirmed} confirmadas, ${metrics.bookingsFinished} finalizadas.',
        icon: Icons.event_available,
      ),
    ];
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Notificaciones',
      child: FutureBuilder<List<_NotificationItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingPanel('Cargando notificaciones...');
          }
          if (snapshot.hasError) {
            return ErrorPanel(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final items = snapshot.data ?? const [];
          return RefreshIndicator(
            color: AppColors.limeGreen,
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(item.icon, color: AppColors.limeGreen),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item.message,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardSurface,
                          title: Text(
                            item.title,
                            style: const TextStyle(color: AppColors.white),
                          ),
                          content: Text(
                            item.message,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}
