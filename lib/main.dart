import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'models/auth_user.dart';
import 'providers/auth_provider.dart';
import 'providers/babysitter_dashboard_provider.dart';
import 'providers/conversations_provider.dart';
import 'providers/parent_provider.dart';
import 'providers/report_provider.dart';
import 'screens/gateway_screen.dart';
import 'screens/parent_discover.dart';
import 'screens/sitter_dashboard.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/babysitter_service.dart';
import 'services/conversation_service.dart';
import 'services/parent_service.dart';
import 'services/report_service.dart';
import 'services/secure_storage_service.dart';
import 'widgets/app_skeleton.dart';

final SecureStorageService _storage = SecureStorageService();
final ApiClient _apiClient = ApiClient(
  baseUrl: 'https://babycare-api-0prm.onrender.com',
  tokenProvider: _storage.readToken,
);
final AuthService _authService = AuthService(
  apiClient: _apiClient,
  storage: _storage,
);
final BabysitterService _babysitterService = BabysitterService(
  apiClient: _apiClient,
);
final ParentService _parentService = ParentService(apiClient: _apiClient);
final ConversationService _conversationService = ConversationService(
  apiClient: _apiClient,
);
final ReportService _reportService = ReportService(apiClient: _apiClient);

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: _authService)..initialize(),
        ),
        ChangeNotifierProvider<ParentProvider>(
          create: (_) => ParentProvider(
            parentService: _parentService,
            babysitterService: _babysitterService,
          ),
        ),
        ChangeNotifierProvider<ConversationsProvider>(
          create: (_) =>
              ConversationsProvider(conversationService: _conversationService),
        ),
        ChangeNotifierProvider<BabysitterDashboardProvider>(
          create: (_) => BabysitterDashboardProvider(
            babysitterService: _babysitterService,
          ),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (_) => ReportProvider(reportService: _reportService),
        ),
      ],
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
          return const Scaffold(body: _AppBootstrapSkeleton());
        }

        if (!authProvider.isAuthenticated) {
          return const GatewayScreen();
        }

        if (authProvider.currentRole == UserRole.babysitter) {
          return const SitterDashboardScreen();
        }

        if (authProvider.currentRole == UserRole.parent) {
          return const ParentDiscoverScreen();
        }

        return const GatewayScreen();
      },
    );
  }
}

class _AppBootstrapSkeleton extends StatelessWidget {
  const _AppBootstrapSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AppSkeletonCircle(size: 88),
            SizedBox(height: 24),
            AppSkeletonBlock(width: 160, height: 22),
            SizedBox(height: 12),
            AppSkeletonBlock(width: 220, height: 14),
          ],
        ),
      ),
    );
  }
}
