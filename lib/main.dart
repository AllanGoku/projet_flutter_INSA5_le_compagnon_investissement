// [AI-GENERATED] Setup, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:le_compagnon_investissement/utils/app_theme.dart';
import 'package:le_compagnon_investissement/views/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Compagnon d\'Investissement',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
