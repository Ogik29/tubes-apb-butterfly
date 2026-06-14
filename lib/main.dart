import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_colors.dart';
import 'app/routes/app_routes.dart';
import 'app/services/api_service.dart';
import 'app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
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
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      final user = await ApiService.getMe();
      if (user != null) {
        setState(() {
          _userName = user.name;
          _isAdmin = user.isAdmin;
          _isLoggedIn = true;
          _isLoading = false;
        });
        return;
      } else {
        await prefs.remove('auth_token');
        await prefs.remove('user_role');
        await prefs.remove('user_name');
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  void setUser({required String name, required bool isAdmin}) {
    setState(() {
      _userName = name;
      _isAdmin = isAdmin;
      _isLoggedIn = name != 'Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return AppState(
      userName: _userName,
      isAdmin: _isAdmin,
      setUser: setUser,
      child: MaterialApp(
        title: 'ButterflyID - Identifikasi Kupu-Kupu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: _isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
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

