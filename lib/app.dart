import 'package:flutter/material.dart';
import 'core/config/app_theme.dart';
import 'navigation/auth_wrapper.dart';

/// Widget raiz do VanPro.
/// Responsabilidade: MaterialApp + Tema + Rota inicial.
class VanProApp extends StatelessWidget {
  const VanProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VanPro - Transporte Escolar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const AuthWrapper(),
    );
  }
}
