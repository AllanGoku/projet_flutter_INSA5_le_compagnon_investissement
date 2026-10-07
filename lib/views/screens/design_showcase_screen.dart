// [AI-GENERATED] Issue #2, Agent, 2024-05-24
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/soft_card.dart';
import '../widgets/performance_text.dart';
import '../widgets/textured_button.dart';
import '../../controllers/data_controller.dart';
import '../../controllers/data_state.dart';

/// Écran bac à sable permettant de visualiser les nouveaux composants "Soft UI"
/// et de tester la connexion à l'API Alpha Vantage.
class DesignShowcaseScreen extends StatefulWidget {
  const DesignShowcaseScreen({super.key});

  @override
  State<DesignShowcaseScreen> createState() => _DesignShowcaseScreenState();
}

class _DesignShowcaseScreenState extends State<DesignShowcaseScreen> {
  final TextEditingController _symbolController = TextEditingController(text: 'AAPL');

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataController = context.watch<DataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Showcase Design & Test API'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            '1. SoftCard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Titre de la carte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Voici un exemple de contenu dans une SoftCard. Les bords sont très arrondis (24px) et l\'ombre est diffuse avec 5% d\'opacité noire.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            '2. PerformanceText',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const SoftCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Gain (%)'),
                    SizedBox(height: 8),
                    PerformanceText(value: 12.5),
                  ],
                ),
                Column(
                  children: [
                    Text('Perte (%)'),
                    SizedBox(height: 8),
                    PerformanceText(value: -4.2),
                  ],
                ),
                Column(
                  children: [
                    Text('Devise'),
                    SizedBox(height: 8),
                    PerformanceText(value: 1250.0, isCurrency: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            '3. TexturedButton (Variantes)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          const Text('Variante Dark (Défaut, style "Ajouter au portefeuille")'),
          const SizedBox(height: 8),
          TexturedButton(
            label: 'Ajouter au portefeuille',
            fullWidth: true,
            variant: ButtonVariant.dark,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clic Variante Dark !')),
              );
            },
          ),
          const SizedBox(height: 16),
          
          const Text('Variante Gradient (Style FAB Simulateur)'),
          const SizedBox(height: 8),
          Center(
            child: TexturedButton(
              icon: const Icon(Icons.rocket_launch, color: Colors.white),
              label: 'Lancer la simulation',
              variant: ButtonVariant.gradient,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clic Variante Gradient !')),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          
          const Text('Variante Light (Style "Analyser")'),
          const SizedBox(height: 8),
          Center(
            child: TexturedButton(
              label: 'Analyser',
              variant: ButtonVariant.light,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clic Variante Light !')),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            '4. Test Connexion API (Alpha Vantage)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _symbolController,
                  decoration: const InputDecoration(
                    labelText: 'Symbole de l\'actif (ex: AAPL, IBM, TSLA)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TexturedButton(
                    label: dataController.state == DataState.loading
                        ? 'Chargement...'
                        : 'Tester le chargement API',
                    icon: dataController.state == DataState.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_download, color: Colors.white),
                    variant: ButtonVariant.dark,
                    onPressed: () {
                      if (dataController.state == DataState.loading) return;
                      final symbol = _symbolController.text.trim().toUpperCase();
                      if (symbol.isNotEmpty) {
                        context.read<DataController>().loadAsset(symbol, isHot: true);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'État du contrôleur : ${dataController.state.name.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStateColor(dataController.state),
                  ),
                ),
                if (dataController.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Erreur : ${dataController.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (dataController.assets.containsKey(_symbolController.text.trim().toUpperCase())) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildAssetDetails(dataController, _symbolController.text.trim().toUpperCase()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(DataState state) {
    switch (state) {
      case DataState.loading:
        return Colors.orange;
      case DataState.success:
        return Colors.green;
      case DataState.offline:
        return Colors.blue;
      case DataState.error:
        return Colors.red;
      case DataState.initial:
      return Colors.grey;
    }
  }

  Widget _buildAssetDetails(DataController controller, String symbol) {
    final asset = controller.assets[symbol]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actif : ${asset.symbol} (${asset.name})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Prix actuel : \$${asset.currentPrice.toStringAsFixed(2)}'),
        Text('Fuseau horaire : ${asset.timezone}'),
        Text('Nombre de points d\'historique : ${asset.timeSeries.length}'),
      ],
    );
  }
}
