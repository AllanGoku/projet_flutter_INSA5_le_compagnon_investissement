// [AI-GENERATED] Issue #1, Agent, 2025-02-23

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_profile.dart';
import '../../utils/validators.dart';
import 'dashboard_screen.dart';

/// Écran d'inscription de l'application.
///
/// Permet à un utilisateur de créer un compte (localement) en renseignant
/// les informations requises avec une validation stricte.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = UserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        country: _countryController.text.trim(),
      );

      final authController = context.read<AuthController>();
      final success = await authController.register(user, _passwordController.text);

      if (success && mounted) {
        // En cas de succès, l'AuthController connecte aussi l'utilisateur.
        // On redirige vers le Dashboard en supprimant la pile de navigation.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.error ?? 'Erreur lors de l\'inscription.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Prénom
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !Validators.isNotEmpty(value)) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Nom
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !Validators.isNotEmpty(value)) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pays
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Pays',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !Validators.isNotEmpty(value)) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !Validators.isNotEmpty(value)) {
                      return 'Champ requis';
                    }
                    if (!Validators.isValidEmail(value)) {
                      return 'Format d\'email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || !Validators.isNotEmpty(value)) {
                      return 'Champ requis';
                    }
                    if (!Validators.isValidPassword(value)) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirmation mot de passe
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || !Validators.isNotEmpty(value)) {
                      return 'Champ requis';
                    }
                    if (!Validators.passwordsMatch(_passwordController.text, value)) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: authController.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authController.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('S\'inscrire', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
