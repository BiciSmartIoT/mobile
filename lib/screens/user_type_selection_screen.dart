import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../theme/colors.dart';
import '../widgets/app_chrome.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Como usaras BiceSmartIoT',
      showDrawer: false,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _TypeCard(
            icon: Icons.directions_bike,
            title: 'Quiero alquilar vehiculos',
            description:
                'Explora vehiculos disponibles y agrega metodos de pago.',
            onTap: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.profile,
            ),
          ),
          const SizedBox(height: 18),
          _TypeCard(
            icon: Icons.two_wheeler,
            title: 'Quiero ofrecer vehiculos',
            description:
                'Registra tus datos de proveedor para solicitar aprobacion.',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.providerRegistration,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.limeGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.black, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
