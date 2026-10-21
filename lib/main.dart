// [AI-GENERATED] Phase 2, Agent, 2025-02-23
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:le_compagnon_investissement/utils/app_theme.dart';
import 'package:le_compagnon_investissement/views/screens/dashboard_screen.dart';
import 'package:le_compagnon_investissement/views/screens/login_screen.dart';
import 'package:le_compagnon_investissement/views/screens/design_showcase_screen.dart';
import 'package:le_compagnon_investissement/controllers/auth_controller.dart';
import 'package:le_compagnon_investissement/controllers/data_controller.dart';
import 'package:le_compagnon_investissement/controllers/portfolio_controller.dart';
import 'package:le_compagnon_investissement/services/api_service.dart';
import 'package:le_compagnon_investissement/services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Chargement des variables d'environnement (.env)
  try {
    await dotenv.load(fileName: ".env", isOptional: true);
  } catch (e) {
    debugPrint("Avertissement: Impossible de charger le fichier .env ($e)");
  }

  // Initialisation du cache
  final cacheService = CacheService();
  await cacheService.initDB();

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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authController = context.read<AuthController>();
    final isLoggedIn = await authController.checkKeepLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          : DevHomeWrapper(
              child: _isLoggedIn ? const DashboardScreen() : const LoginScreen(),
            ),
    );
  }
}

/// [PROVISOIRE] Widget d'emballage pour afficher un bouton flottant permettant
/// d'accéder à l'écran de présentation du nouveau design depuis n'importe où.
class DevHomeWrapper extends StatelessWidget {
  final Widget child;

  const DevHomeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DesignShowcaseScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.mint,
        icon: const Icon(Icons.palette, color: Colors.white),
        label: const Text('Voir Design', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
