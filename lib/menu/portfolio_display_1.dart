import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // Import de la bibliothèque intl
import 'package:url_launcher/url_launcher.dart'; // Import de la bibliothèque url_launcher
import 'package:RealToken/menu/token_bottom_sheet.dart';
import '../generated/l10n.dart'; // Import des traductions

// Fonction pour extraire le nom de la ville à partir du fullName
String extractCity(String fullName) {
  List<String> parts = fullName.split(',');
  return parts.length >= 2 ? parts[1].trim() : S.current.unknownCity; // Traduction pour "Ville inconnue"
}

// Fonction pour déterminer la couleur de la pastille en fonction du taux de location
Color getRentalStatusColor(int rentedUnits, int totalUnits) {
  if (rentedUnits == 0) {
    return Colors.red; // Aucun logement loué
  } else if (rentedUnits == totalUnits) {
    return Colors.green; // Tous les logements sont loués
  } else {
    return Colors.orange; // Partiellement loué
  }
}

class PortfolioDisplay1 extends StatelessWidget {
  final List<Map<String, dynamic>> portfolio;

  const PortfolioDisplay1({Key? key, required this.portfolio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 20),
        itemCount: portfolio.length,
        itemBuilder: (context, index) {
          // Récupération des données pour chaque élément du portefeuille
          final token = portfolio[index];
          final isWallet = token['source'] == 'Wallet';
          final isRMM = token['source'] == 'RMM';
          final city = extractCity(token['fullName'] ?? '');

          // Récupération des unités louées et totales pour déterminer la couleur de la pastille
          final rentedUnits = token['rentedUnits'] ?? 0;
          final totalUnits = token['totalUnits'] ?? 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => showTokenDetails(context, token),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Conteneur avec image et superposition du texte de la ville
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Image de l'avatar avec hauteur fixe
                              Container(
                                width: 150,
                                height: double.infinity,  // Hauteur ajustée à l'élément adjacent
                                child: CachedNetworkImage(
                                  imageUrl: token['imageLink'] ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              // Superposition du texte de la ville et pastille de location
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  color: Colors.black54,
                                  child: Stack(
                                    children: [
                                      // Pastille pour indiquer le statut de location, alignée tout à gauche
                                      Positioned(
                                        left: 0, // Position tout à gauche
                                        top: 0, // Aligner verticalement au centre
                                        bottom: 0,
                                        child: Container(
                                          width: 12, // Taille réduite de la pastille
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: getRentalStatusColor(
                                              rentedUnits, totalUnits,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Texte de la ville centré indépendamment de la pastille
                                      Center(
                                        child: Text(
                                          city,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          // Carte à droite de l'image
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            color: Theme.of(context).cardColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        token['shortName'] ?? S.of(context).nameUnavailable, // Traduction pour "Nom indisponible"
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      // Pastille pour source avec texte "Wallet", "RMM", ou "Other"
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0, vertical: 3.0),
                                        decoration: BoxDecoration(
                                          color: isWallet
                                              ? Colors.grey
                                              : isRMM
                                                  ? Color.fromARGB(255, 165, 100, 21)
                                                  : Colors.grey,
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          isWallet
                                              ? S.of(context).wallet // Traduction pour "Wallet"
                                              : isRMM
                                                  ? 'RMM'
                                                  : S.of(context).other, // Traduction pour "Other"
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Affichage de Amount et Total Tokens
                                  Text(
                                    '${S.of(context).totalValue}: ${formatCurrency(token['totalValue'])}', // Traduction pour "Total Value"
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    '${S.of(context).amount}: ${token['amount']} / ${token['totalTokens']}', // Traduction pour "Amount"
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  // Affichage de l'APY arrondi à 2 chiffres après la virgule
                                  Text(
                                    '${S.of(context).apy}: ${token['annualPercentageYield']?.toStringAsFixed(2)}%', // Traduction pour "APY"
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${S.of(context).revenue}:', // Traduction pour "Revenue"
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(S.of(context).day, // Traduction pour "Day"
                                                style: TextStyle(fontSize: 13)),
                                            Text(
                                                '${formatCurrency(token['dailyIncome'] ?? 0)}',
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(S.of(context).month, // Traduction pour "Month"
                                                style: TextStyle(fontSize: 13)),
                                            Text(
                                                '${formatCurrency(token['monthlyIncome'] ?? 0)}',
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(S.of(context).year, // Traduction pour "Year"
                                                style: TextStyle(fontSize: 13)),
                                            Text(
                                                '${formatCurrency(token['yearlyIncome'] ?? 0)}',
                                                style: const TextStyle(
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
