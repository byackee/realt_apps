import 'package:flutter/material.dart';

class PortfolioDisplay1 extends StatelessWidget {
  final List<Map<String, dynamic>> portfolio;

  const PortfolioDisplay1({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: portfolio.length,
      itemBuilder: (context, index) {
        final token = portfolio[index];
        final isWallet = token['source'] == 'Wallet'; // Vérification de la source

        return Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                token['imageLink'],
                width: double.infinity, // Prend toute la largeur disponible
                height: 200,
                fit: BoxFit.cover, // Image ajustée
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      token['shortName'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Pastille pour indiquer la source (Wallet ou RMM)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isWallet ? Colors.green : Colors.blue, // Couleur en fonction de la source
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        isWallet ? 'Wallet' : 'RMM',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Amount: ${token['amount']} / Total Tokens: ${token['totalTokens']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'APY: ${token['annualPercentageYield'].toStringAsFixed(2)}%',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total Value: \$${token['totalValue'].toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Revenue:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Day'),
                        Text('\$${token['dailyIncome'].toStringAsFixed(2)}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Month'),
                        Text('\$${token['monthlyIncome'].toStringAsFixed(2)}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Year'),
                        Text('\$${token['yearlyIncome'].toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10), // Ajout d'espace pour aérer le contenu
            ],
          ),
        );
      },
    );
  }
}
