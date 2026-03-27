import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'models/auth_user.dart';
import 'providers/auth_provider.dart';
import 'screens/gateway_screen.dart';
import 'screens/sitter_dashboard.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';

final SecureStorageService _storage = SecureStorageService();
final ApiClient _apiClient = ApiClient(
  baseUrl: 'https://babycare-api-0prm.onrender.com',
  tokenProvider: _storage.readToken,
);
final AuthService _authService = AuthService(
  apiClient: _apiClient,
  storage: _storage,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BabyCareApp());
}

class BabyCareApp extends StatelessWidget {
  const BabyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(authService: _authService)..initialize(),
      child: MaterialApp(
        title: 'BabyCare',
        theme: BabyCareTheme.buildTheme(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return ColoredBox(
            color: BabyCareTheme.universalWhite,
            child: SafeArea(child: child ?? const SizedBox.shrink()),
          );
        },
        home: const _AppBootstrapScreen(),
      ),
    );
  }
}

class _AppBootstrapScreen extends StatelessWidget {
  const _AppBootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const GatewayScreen();
        }

        if (authProvider.currentRole == UserRole.babysitter) {
          return const SitterDashboardScreen();
        }

        return const GatewayScreen();
      },
    );
  }
}
