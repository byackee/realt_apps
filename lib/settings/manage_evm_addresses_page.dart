import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart'; // Import de Hive

class ManageEvmAddressesPage extends StatefulWidget {
  const ManageEvmAddressesPage({super.key});

  @override
  _ManageEthAddressesPageState createState() => _ManageEthAddressesPageState();
}

class _ManageEthAddressesPageState extends State<ManageEvmAddressesPage> {
  final TextEditingController _ethAddressController = TextEditingController();
  List<String> ethAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses(); // Charger les adresses sauvegardées
  }

  @override
  void dispose() {
    _ethAddressController.dispose();
    super.dispose();
  }

  // Charger les adresses sauvegardées depuis SharedPreferences
  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ethAddresses = prefs.getStringList('evmAddresses') ?? [];
    });
  }

  // Sauvegarder l'adresse EVM dans SharedPreferences
  Future<void> _saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ethAddresses.add(address);
    });
    await prefs.setStringList('evmAddresses', ethAddresses);
    _resetLastFetchTime(); // Réinitialiser la valeur de lastFetchTime
  }

  // Supprimer une adresse EVM
  Future<void> _deleteAddress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ethAddresses.removeAt(index);
    });
    await prefs.setStringList('ethAddresses', ethAddresses);
    _resetLastFetchTime(); // Réinitialiser la valeur de lastFetchTime
  }

  // Réinitialiser la valeur de lastFetchTime dans Hive
  Future<void> _resetLastFetchTime() async {
    var box = await Hive.openBox('dashboardTokens');
    await box.delete('lastFetchTime'); // Supprimer la clé lastFetchTime
    await box.delete('lastRMMFetchTime'); // Si nécessaire, réinitialiser également pour RMM
  }

  // Fonction pour valider l'adresse EVM
  String? _validateEVMAddress(String address) {
    if (address.startsWith('0x') && address.length == 42) {
      return null; // Adresse valide
    }
    return 'Invalid EVM address';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Applique le background du thème
      appBar: AppBar(
        title: const Text('Manage EVM Addresses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ethAddressController,
              decoration: const InputDecoration(
                labelText: 'EVM Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String enteredAddress = _ethAddressController.text;
                if (_validateEVMAddress(enteredAddress) == null) {
                  _saveAddress(enteredAddress);
                  _ethAddressController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Address saved: $enteredAddress')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid EVM address')),
                  );
                }
              },
              child: const Text('Save Address'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ethAddresses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(ethAddresses[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteAddress(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Address deleted')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
