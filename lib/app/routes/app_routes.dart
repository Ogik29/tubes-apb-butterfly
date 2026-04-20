import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/scan/result_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/collection/collection_screen.dart';
import '../screens/collection/species_detail_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/admin/species_form_screen.dart';
import '../models/butterfly_model.dart';
import '../models/scan_result_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String scan = '/scan';
  static const String result = '/result';
  static const String history = '/history';
  static const String collection = '/collection';
  static const String speciesDetail = '/species-detail';
  static const String adminPanel = '/admin';
  static const String speciesForm = '/species-form';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        dashboard: (context) => const DashboardScreen(),
        scan: (context) => const ScanScreen(),
        history: (context) => const HistoryScreen(),
        collection: (context) => const CollectionScreen(),
        adminPanel: (context) => const AdminPanelScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case result:
        final args = settings.arguments as ScanResultModel?;
        return MaterialPageRoute(
          builder: (context) => ResultScreen(result: args),
        );
      case speciesDetail:
        final args = settings.arguments as ButterflyModel;
        return MaterialPageRoute(
          builder: (context) => SpeciesDetailScreen(butterfly: args),
        );
      case speciesForm:
        final args = settings.arguments as ButterflyModel?;
        return MaterialPageRoute(
          builder: (context) => SpeciesFormScreen(butterfly: args),
        );
      default:
        return null;
    }
  }
}
