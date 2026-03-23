import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/gateway_screen.dart';

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
    return MaterialApp(
      title: 'BabyCare',
      theme: BabyCareTheme.buildTheme(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ColoredBox(
          color: BabyCareTheme.universalWhite,
          child: SafeArea(child: child ?? const SizedBox.shrink()),
        );
      },
      home: const GatewayScreen(),
    );
  }
}
