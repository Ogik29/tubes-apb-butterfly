import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ButterflyApp());
}

class ButterflyApp extends StatefulWidget {
  const ButterflyApp({super.key});

  @override
  State<ButterflyApp> createState() => _ButterflyAppState();
}

class _ButterflyAppState extends State<ButterflyApp> {
  String _userName = 'Pengguna';
  bool _isAdmin = false;

  void setUser({required String name, required bool isAdmin}) {
    setState(() {
      _userName = name;
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      userName: _userName,
      isAdmin: _isAdmin,
      setUser: setUser,
      child: MaterialApp(
        title: 'ButterflyID - Identifikasi Kupu-Kupu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

/// Inherited widget sederhana untuk state global
class AppState extends InheritedWidget {
  final String userName;
  final bool isAdmin;
  final void Function({required String name, required bool isAdmin}) setUser;

  const AppState({
    super.key,
    required this.userName,
    required this.isAdmin,
    required this.setUser,
    required super.child,
  });

  static AppState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }

  @override
  bool updateShouldNotify(AppState oldWidget) {
    return oldWidget.userName != userName || oldWidget.isAdmin != isAdmin;
  }
}
