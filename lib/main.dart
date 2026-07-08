import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/iot_control_screen.dart';
import 'screens/my_vehicles_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/provider_income_screen.dart';
import 'screens/provider_profile_screen.dart';
import 'screens/provider_registration_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/user_type_selection_screen.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BiceSmartIoTApp());
}

class BiceSmartIoTApp extends StatelessWidget {
  const BiceSmartIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiceSmartIoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: AppColors.limeGreen,
          secondary: AppColors.mutedGreen,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.black,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.signIn,
      routes: {
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.userType: (_) => const UserTypeSelectionScreen(),
        AppRoutes.providerRegistration: (_) =>
            const ProviderRegistrationScreen(),
        AppRoutes.profile: (_) => const ProviderProfileScreen(),
        AppRoutes.vehicles: (_) => const MyVehiclesScreen(),
        AppRoutes.addVehicle: (_) => const AddVehicleScreen(),
        AppRoutes.iotControl: (_) => const IotControlScreen(),
        AppRoutes.payments: (_) => const PaymentMethodsScreen(),
        AppRoutes.income: (_) => const ProviderIncomeScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
      },
    );
  }
}
