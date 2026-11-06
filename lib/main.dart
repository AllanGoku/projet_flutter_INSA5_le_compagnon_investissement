// [AI-GENERATED] Phase 2 & Fix, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_compagnon_investissement/utils/app_theme.dart';
import 'package:le_compagnon_investissement/views/screens/dashboard_screen.dart';
import 'package:le_compagnon_investissement/views/screens/login_screen.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/controllers/data_controller.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Blocage de l'orientation en mode portrait (vertical) uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Chargement des variables d'environnement (.env)
  try {
    await dotenv.load(fileName: ".env", isOptional: true);
  } catch (e) {
    debugPrint("Avertissement: Impossible de charger le fichier .env ($e)");
  }

  // Initialisation du cache
  final cacheService = CacheService();
  try {
    await cacheService.initDB();
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation de la DB cache: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(
          create: (_) => DataController(
            apiService: ApiService(),
            cacheService: cacheService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PortfolioController(
            cacheService: cacheService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final authController = context.read<AuthController>();
      await authController.checkKeepLoggedIn();
    } catch (e) {
      debugPrint("Erreur lors de la vérification de session: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final bool isLoggedIn = authController.currentUser != null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Le Compagnon d\'Investissement',
      theme: AppTheme.lightTheme,
      home: _isCheckingAuth
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (isLoggedIn ? const DashboardScreen() : const LoginScreen()),
    );
  }
}
