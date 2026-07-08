import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../models/api_models.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  late Future<List<VehicleResource>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.ownVehicles();
  }

  void _refresh() {
    setState(() => _future = ApiClient.instance.ownVehicles());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Mis vehiculos',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppColors.white),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addVehicle),
        ),
      ],
      child: FutureBuilder<List<VehicleResource>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingPanel('Consultando vehiculos...');
          }
          if (snapshot.hasError) {
            return ErrorPanel(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final vehicles = snapshot.data ?? const [];
          if (vehicles.isEmpty) {
            return ErrorPanel(
              message:
                  'No hay vehiculos publicados todavia. Puedes intentar agregar uno si tu proveedor esta aprobado.',
              onRetry: _refresh,
            );
          }

          return RefreshIndicator(
            color: AppColors.limeGreen,
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _VehicleCard(vehicle: vehicles[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final VehicleResource vehicle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.limeGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_bike, color: AppColors.black),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.status,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                'S/ ${vehicle.hourlyPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.limeGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (vehicle.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              vehicle.description,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Ubicacion: ${vehicle.latitude.toStringAsFixed(4)}, ${vehicle.longitude.toStringAsFixed(4)}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'ESP32: ${vehicle.deviceId?.isNotEmpty == true ? vehicle.deviceId : 'sin asignar'}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Control IoT en vivo',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.iotControl,
              arguments: vehicle,
            ),
          ),
        ],
      ),
    );
  }
}
