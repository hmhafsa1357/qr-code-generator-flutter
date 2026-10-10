import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QrGeneratorApp());
}

class QrGeneratorApp extends StatefulWidget {
  const QrGeneratorApp({super.key});

  @override
  State<QrGeneratorApp> createState() => _QrGeneratorAppState();
}

class _QrGeneratorAppState extends State<QrGeneratorApp> {
  // Defaults to the device's system setting; the toggle in the app bar
  // overrides this once the user picks light or dark explicitly.
  ThemeMode _themeMode = ThemeMode.system;

  void _handleThemeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Generator',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Builder(
        builder: (context) {

          final effectiveMode = _themeMode == ThemeMode.system
              ? (Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light)
              : _themeMode;
          return HomeScreen(
            themeMode: effectiveMode,
            onThemeChanged: _handleThemeChanged,
          );
        },
      ),
    );
  }
}