Proposition de Projet : Le Compagnon d’Investissement

Le problème traité et l’utilisateur cible ;
* Cible : Les novices et débutants souhaitant faire leurs premiers pas en investissement.
* Problème : Démystifier l'investissement financier en aidant l'utilisateur à comprendre les mécanismes via une approche d'interaction et de simulation, sans aucun risque financier (aucune transaction réelle).

Les principales fonctionnalités envisagées ;
* Exploration pédagogique et visualisation des actions et ETF disponibles.
* Visualisations détaillées d’un actif : cours actuel, historique (courbe, date précise), ouverture du marché, détails de l’origine.
* Ajout de bulles d'aide interactives (logo « ? ») pour expliquer simplement différentes informations financières (définition d'un ETF, principe de l'ouverture du marché).
* Formulaire avec validation permettant l'ajout d'une action à un portefeuille purement fictif (avec saisie de la quantité).
* Classement ludique et fictif : comparaison de l'évolution de son portefeuille et de ses dépenses face à de faux profils d'utilisateurs générés par l'application pour stimuler l'apprentissage.
* Simulateur pédagogique (DCA) : scénarios permettant de répondre à la question "et si j’avais investi X euros par mois", en comparant un actif simulé face à ceux du portefeuille.
* Tableau de bord de suivi : synthèse du portefeuille fictif avec le nombre d’actifs possédés, un graphique des gains en euros, et une case cliquable pour basculer l'affichage du gain entre pourcentages et euros.
* Système de succès déblocables pour récompenser la progression.
* Affichage contextuel de conseils sur l’accueil (avec possibilité de masquer définitivement).
* Page d’aide et lexique (informations sur les calculs effectués par l'application, sur les termes techniques).

Les données externes nécessaires et les API envisagées ;
* Informations financières : cours quotidiens, historiques et détails des actifs (actions/ETF).
* API envisagée : Alpha Vantage.

Les données qui seront conservées localement (Persistance et Cache) ;
*	Données utilisateur : Portefeuille fictif (actions/ETF possédées et historique mensuel), profil de l'utilisateur, succès débloqués et préférences de suivi.
*	Cache API : Cours sur 7 jours des autres actions consultées et historiques des actifs possédés.
*	Stratégie de cache : L'actualisation des données de l'API se fera de manière espacée (par exemple toutes les 10 minutes ou toutes les heures) afin de limiter le volume d'appels réseau, respecter les limites de l'API gratuite, et garantir un fonctionnement fluide même en l'absence de réseau.

Les principaux états de l’application ;
* États asynchrones liés aux requêtes : En cours de chargement (chargement initial ou actualisation), Données disponibles (succès de l'API), Erreur de récupération des données.
* États de connectivité : Connecté à internet, Hors-connexion.
* État d'information dégradée : Affichage de la date et de l'heure de la dernière actualisation si l'application charge le cache hors-connexion.
* États métier (Synchrones) : Portefeuille vide / avec actifs

Les calculs métier envisagés ;
* Performance globale de l’investissement (%).
* Plus-value / moins-value (en euros).
* Valeur totale courante du portefeuille fictif.
* Simulation de rendement composé ou DCA (Dollar-Cost Averaging).

Une première idée des animations et visualisations envisagées ;
* Visualisation graphique : Graphique d'évolution se construisant au fur et à mesure de l'affichage.
* Animations programmées (codées manuellement) : Carte d’action retournable (flip) pour dévoiler les détails techniques au dos, et animation fluide des chiffres (montée ou descente façon "score") lors de l'actualisation du portefeuille.
* Animations d'interface (possiblement via packages) : Visuel d’une carte bleue glissant à l’achat fictif, apparition des succès avec confettis sur l’écran, et déplacement automatique et fluide de l'utilisateur dans le classement.
* ...