import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/apple_theme.dart';
import 'pages/welcome_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'ClinicaApp',
      debugShowCheckedModeBanner: false,
      theme: AppleTheme.lightTheme,
      home: const WelcomePage(),
    );
  }
}
