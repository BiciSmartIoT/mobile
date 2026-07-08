import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '10');
  final _latController = TextEditingController(text: '-12.0464');
  final _lngController = TextEditingController(text: '-77.0428');
  final _deviceIdController = TextEditingController(text: 'esp32-demo-01');
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (title.isEmpty || description.isEmpty) {
      showAppMessage(context, 'Completa titulo y descripcion.');
      return;
    }
    if (price == null || price <= 0 || lat == null || lng == null) {
      showAppMessage(context, 'Precio o coordenadas invalidas.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiClient.instance.createVehicle(
        title: title,
        description: description,
        hourlyPrice: price,
        latitude: lat,
        longitude: lng,
        deviceId: _deviceIdController.text.trim(),
      );
      if (!mounted) return;
      showAppMessage(context, 'Vehiculo registrado correctamente.');
      Navigator.pushReplacementNamed(context, AppRoutes.vehicles);
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
      title: 'Agregar vehiculo',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const AppCard(
            child: Text(
              'El backend solo permite crear vehiculos a proveedores aprobados. Si recibes 403, completa onboarding y aprobacion admin.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(label: 'Titulo', controller: _titleController),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Descripcion',
            controller: _descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'Precio por hora',
            controller: _priceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          AppTextField(
            label: 'ESP32 device ID',
            controller: _deviceIdController,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Latitud',
                  controller: _latController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Longitud',
                  controller: _lngController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Guardar en backend',
            loading: _loading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
