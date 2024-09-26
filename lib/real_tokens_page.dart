import 'package:flutter/material.dart';
import 'api_service.dart';

class RealTokensPage extends StatefulWidget {
  const RealTokensPage({super.key});

  @override
  _RealTokensPageState createState() => _RealTokensPageState();
}

class _RealTokensPageState extends State<RealTokensPage> {
  Future<List<dynamic>>? _realTokens;

  @override
  void initState() {
    super.initState();
    _realTokens = ApiService.fetchRealTokens(); // Charger les tokens RealTokens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RealTokens'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _realTokens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching RealTokens'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No RealTokens found'));
          }

          final realTokens = snapshot.data!;
          return ListView.builder(
            itemCount: realTokens.length,
            itemBuilder: (context, index) {
              final token = realTokens[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(token['fullName']),
                  subtitle: Text('Price: \$${token['tokenPrice'].toString()}'),
                  leading: Image.network(token['imageLink'][0]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
