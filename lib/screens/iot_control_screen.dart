import 'dart:async';

import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class IotControlScreen extends StatefulWidget {
  const IotControlScreen({super.key});

  @override
  State<IotControlScreen> createState() => _IotControlScreenState();
}

class _IotControlScreenState extends State<IotControlScreen> {
  static const _fallbackDeviceId = 'esp32-demo-01';

  final _deviceIdController = TextEditingController();
  final _speedController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _radiusController = TextEditingController();

  VehicleResource? _vehicle;
  IotDeviceConfigResource? _config;
  IotDeviceStateResource? _state;
  Timer? _pollTimer;
  bool _loading = true;
  bool _savingConfig = false;
  bool _savingDevice = false;
  String? _commandInFlight;
  String? _error;

  String get _deviceId {
    final value = _deviceIdController.text.trim();
    return value.isEmpty ? _fallbackDeviceId : value;
  }

  bool get _isOnline {
    final updatedAt = _state?.updatedAt;
    if (updatedAt == null) return false;
    return DateTime.now().toUtc().difference(updatedAt.toUtc()).inSeconds <= 45;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vehicle != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VehicleResource) {
      _vehicle = args;
      _deviceIdController.text =
          args.deviceId?.isNotEmpty == true ? args.deviceId! : _fallbackDeviceId;
    } else {
      _deviceIdController.text = _fallbackDeviceId;
    }

    _loadAll();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshState());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _deviceIdController.dispose();
    _speedController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final config = await ApiClient.instance.iotDeviceConfig(_deviceId);
      final state = await ApiClient.instance.iotDeviceState(_deviceId);
      if (!mounted) return;
      setState(() {
        _config = config;
        _state = state;
        _syncConfigFields(config);
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshState() async {
    if (_loading || !ApiClient.instance.isAuthenticated) return;
    try {
      final state = await ApiClient.instance.iotDeviceState(_deviceId);
      if (!mounted) return;
      setState(() {
        _state = state;
        _error = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    }
  }

  Future<void> _saveDeviceId() async {
    final vehicle = _vehicle;
    if (vehicle == null) {
      showAppMessage(context, 'Abre esta pantalla desde un vehiculo.');
      return;
    }
    if (_deviceId.trim().isEmpty) {
      showAppMessage(context, 'Ingresa un device ID valido.');
      return;
    }

    setState(() => _savingDevice = true);
    try {
      final updated = await ApiClient.instance.updateVehicle(
        vehicleId: vehicle.id,
        deviceId: _deviceId,
      );
      if (!mounted) return;
      setState(() => _vehicle = updated);
      showAppMessage(context, 'ESP32 asignado al vehiculo.');
      await _loadAll();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _savingDevice = false);
    }
  }

  Future<void> _saveConfig() async {
    final speed = double.tryParse(_speedController.text.trim());
    final lat = double.tryParse(_latController.text.trim());
    final lon = double.tryParse(_lonController.text.trim());
    final radius = double.tryParse(_radiusController.text.trim());

    if (speed == null || speed <= 0 || radius == null || radius <= 0) {
      showAppMessage(context, 'Velocidad o radio invalidos.');
      return;
    }
    if (lat == null || lat < -90 || lat > 90 || lon == null || lon < -180 || lon > 180) {
      showAppMessage(context, 'Coordenadas invalidas.');
      return;
    }

    setState(() => _savingConfig = true);
    try {
      final config = await ApiClient.instance.updateIotDeviceConfig(
        deviceId: _deviceId,
        speedLimitKmph: speed,
        geofenceCenterLat: lat,
        geofenceCenterLon: lon,
        geofenceRadiusMeters: radius,
      );
      if (!mounted) return;
      setState(() {
        _config = config;
        _syncConfigFields(config);
      });
      showAppMessage(context, 'Configuracion enviada al ESP32.');
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _savingConfig = false);
    }
  }

  Future<void> _sendCommand(String type) async {
    setState(() => _commandInFlight = type);
    try {
      await ApiClient.instance.sendIotCommand(
        deviceId: _deviceId,
        type: type,
        reason: 'Comando $type desde app movil',
      );
      if (!mounted) return;
      showAppMessage(context, 'Comando $type enviado.');
      await _refreshState();
    } on ApiException catch (error) {
      if (!mounted) return;
      showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _commandInFlight = null);
    }
  }

  void _syncConfigFields(IotDeviceConfigResource config) {
    _speedController.text = config.speedLimitKmph.toStringAsFixed(1);
    _latController.text = config.geofenceCenterLat.toStringAsFixed(6);
    _lonController.text = config.geofenceCenterLon.toStringAsFixed(6);
    _radiusController.text = config.geofenceRadiusMeters.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Control IoT',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: _loadAll,
        ),
      ],
      child: _loading
          ? loadingPanel('Conectando con el dispositivo...')
          : RefreshIndicator(
              color: AppColors.limeGreen,
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _HeaderCard(
                    vehicle: _vehicle,
                    deviceId: _deviceId,
                    online: _isOnline,
                    lastSeen: _state?.updatedAt,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    AppCard(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.orange),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _DeviceAssignmentCard(
                    controller: _deviceIdController,
                    loading: _savingDevice,
                    onSave: _saveDeviceId,
                  ),
                  const SizedBox(height: 16),
                  _TelemetryCard(state: _state, online: _isOnline),
                  const SizedBox(height: 16),
                  _CommandCard(
                    commandInFlight: _commandInFlight,
                    onCommand: _sendCommand,
                  ),
                  const SizedBox(height: 16),
                  _ConfigCard(
                    config: _config,
                    speedController: _speedController,
                    latController: _latController,
                    lonController: _lonController,
                    radiusController: _radiusController,
                    loading: _savingConfig,
                    onSave: _saveConfig,
                  ),
                ],
              ),
            ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.vehicle,
    required this.deviceId,
    required this.online,
    required this.lastSeen,
  });

  final VehicleResource? vehicle;
  final String deviceId;
  final bool online;
  final DateTime? lastSeen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: online ? AppColors.limeGreen : AppColors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              online ? Icons.sensors : Icons.sensors_off,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle?.title ?? 'Unidad IoT',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$deviceId - ${online ? 'Online' : 'Sin senal'}',
                  style: TextStyle(
                    color: online ? AppColors.limeGreen : AppColors.orange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lastSeen == null
                      ? 'Sin eventos recibidos'
                      : 'Ultimo evento: ${lastSeen!.toLocal()}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceAssignmentCard extends StatelessWidget {
  const _DeviceAssignmentCard({
    required this.controller,
    required this.loading,
    required this.onSave,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ESP32 asignado',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AppTextField(label: 'Device ID', controller: controller),
          const SizedBox(height: 12),
          AppButton(
            label: 'Guardar device ID',
            loading: loading,
            onPressed: onSave,
            outline: true,
          ),
        ],
      ),
    );
  }
}

class _TelemetryCard extends StatelessWidget {
  const _TelemetryCard({required this.state, required this.online});

  final IotDeviceStateResource? state;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final blocked = state?.blocked == true;
    final outside = state?.insideGeofence == false;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Telemetria en vivo',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusChip(
                label: online ? 'ONLINE' : 'OFFLINE',
                color: online ? AppColors.limeGreen : AppColors.orange,
              ),
              _StatusChip(
                label: blocked ? 'BLOQUEADO' : 'LIBRE',
                color: blocked ? AppColors.red : AppColors.limeGreen,
              ),
              _StatusChip(
                label: outside ? 'FUERA DE ZONA' : 'DENTRO DE ZONA',
                color: outside ? AppColors.red : AppColors.limeGreen,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Evento', value: state?.eventType ?? 'Pendiente'),
          _InfoRow(label: 'Mensaje', value: state?.message ?? 'Esperando ESP32'),
          _InfoRow(
            label: 'Velocidad',
            value: '${state?.speedKmph?.toStringAsFixed(1) ?? '0.0'} km/h',
          ),
          _InfoRow(
            label: 'GPS',
            value: state?.latitude == null || state?.longitude == null
                ? 'Sin fix GPS'
                : '${state!.latitude!.toStringAsFixed(6)}, ${state!.longitude!.toStringAsFixed(6)}',
          ),
          _InfoRow(
            label: 'Servo',
            value: state?.lockState ?? (blocked ? 'LOCKED' : 'UNLOCKED'),
          ),
        ],
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({
    required this.commandInFlight,
    required this.onCommand,
  });

  final String? commandInFlight;
  final ValueChanged<String> onCommand;

  @override
  Widget build(BuildContext context) {
    final busy = commandInFlight != null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Comandos remotos',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: commandInFlight == 'LOCK' ? 'Enviando...' : 'Bloquear',
                  loading: commandInFlight == 'LOCK',
                  onPressed: busy ? null : () => onCommand('LOCK'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: commandInFlight == 'UNLOCK' ? 'Enviando...' : 'Desbloquear',
                  loading: commandInFlight == 'UNLOCK',
                  onPressed: busy ? null : () => onCommand('UNLOCK'),
                  outline: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(
            label: commandInFlight == 'RESET' ? 'Enviando...' : 'Reset ESP32',
            loading: commandInFlight == 'RESET',
            onPressed: busy ? null : () => onCommand('RESET'),
            outline: true,
          ),
        ],
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.config,
    required this.speedController,
    required this.latController,
    required this.lonController,
    required this.radiusController,
    required this.loading,
    required this.onSave,
  });

  final IotDeviceConfigResource? config;
  final TextEditingController speedController;
  final TextEditingController latController;
  final TextEditingController lonController;
  final TextEditingController radiusController;
  final bool loading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Zona y limite',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          if (config?.updatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Actualizado: ${config!.updatedAt!.toLocal()}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          AppTextField(
            label: 'Limite de velocidad km/h',
            controller: speedController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Centro latitud',
            controller: latController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Centro longitud',
            controller: lonController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Radio permitido en metros',
            controller: radiusController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Enviar configuracion',
            loading: loading,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
