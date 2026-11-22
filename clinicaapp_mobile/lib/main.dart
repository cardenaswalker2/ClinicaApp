import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_config.dart';
import 'theme/apple_theme.dart';
import 'pages/welcome_page.dart';
import 'pages/main_navigation_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadSession();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const ClinicaAppMobile());
}

class ClinicaAppMobile extends StatelessWidget {
  const ClinicaAppMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final hasSession = AppConfig.userEmail != null && AppConfig.userEmail!.isNotEmpty;
    return MaterialApp(
      title: 'ClinicaApp',
      debugShowCheckedModeBanner: false,
      theme: AppleTheme.lightTheme,
      home: hasSession ? const MainNavigationPage() : const WelcomePage(),
    );
  }
}
