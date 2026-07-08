import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../services/api_client.dart';
import '../theme/colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.fontSize = 28,
    this.centered = false,
    this.dark = true,
  });

  final double fontSize;
  final bool centered;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final logo = Text(
      'BiceSmartIoT',
      textAlign: centered ? TextAlign.center : TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: dark ? AppColors.limeGreen : AppColors.black,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
    return centered ? Center(child: logo) : logo;
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.showDrawer = true,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final bool showDrawer;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      drawer: showDrawer ? const AppDrawer() : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  if (showDrawer)
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: AppColors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Expanded(
                    child: BrandLogo(centered: true),
                  ),
                  if (actions.isEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: AppColors.white,
                      ),
                      onPressed: () {
                        if (ModalRoute.of(context)?.settings.name !=
                            AppRoutes.profile) {
                          Navigator.pushNamed(context, AppRoutes.profile);
                        }
                      },
                    )
                  else
                    Row(children: actions),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
            return Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.10,
                  color: AppColors.limeGreen,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      28,
                      28,
                      28,
                      keyboardBottom > 0 ? keyboardBottom + 28 : 28,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 480,
                          minHeight: constraints.maxHeight - 56,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),
                            const BrandLogo(fontSize: 34, centered: true),
                            const SizedBox(height: 24),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 28),
                            child,
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ApiClient.instance.currentUser;
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const BrandLogo(centered: true, dark: false),
                  const SizedBox(height: 20),
                  Text(
                    user?.fullName ?? 'Invitado',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'Sin sesion activa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.black.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Perfil',
                    route: AppRoutes.profile,
                  ),
                  _DrawerItem(
                    icon: Icons.directions_bike,
                    title: 'Vehiculos',
                    route: AppRoutes.vehicles,
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline,
                    title: 'Agregar vehiculo',
                    route: AppRoutes.addVehicle,
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Ingresos',
                    route: AppRoutes.income,
                  ),
                  _DrawerItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Metodos de pago',
                    route: AppRoutes.payments,
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    route: AppRoutes.notifications,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.black),
              title: const Text('Cerrar sesion'),
              onTap: () async {
                await ApiClient.instance.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.signIn,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(title),
      onTap: () => _go(context, route),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.limeGreen.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.white.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.limeGreen, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outline = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.black,
            ),
          )
        : Text(
            label,
            style: TextStyle(
              color: outline ? AppColors.white : AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );

    if (outline) {
      return SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.limeGreen, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.limeGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: AppColors.limeGreen, size: 42),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.white),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                AppButton(label: 'Reintentar', onPressed: onRetry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Widget loadingPanel([String text = 'Cargando datos...']) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.limeGreen),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: AppColors.textMuted)),
      ],
    ),
  );
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.darkSurface,
    ),
  );
}

Future<void> _go(BuildContext context, String route) async {
  Navigator.pop(context);
  if (ModalRoute.of(context)?.settings.name == route) return;
  await Navigator.pushNamed(context, route);
}
