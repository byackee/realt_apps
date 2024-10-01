import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../api/api_service.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Future<List<dynamic>>? _walletTokens;
  Future<List<dynamic>>? _rmmTokens;
  Future<List<dynamic>>? _realTokens;

  // Create a PopupController to manage the popups
  final PopupController _popupController = PopupController();

  @override
  void initState() {
    super.initState();
    _walletTokens = ApiService.fetchTokens(); // Load Wallet tokens
    _rmmTokens = ApiService.fetchRMMTokens(); // Load RMM tokens
    _realTokens = ApiService.fetchRealTokens(); // Load RealTokens
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_walletTokens!, _rmmTokens!, _realTokens!]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading map data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tokens found in the wallet or RMM'));
          }

          final walletTokens = snapshot.data![0][0]['balances'];
          final rmmTokens = snapshot.data![1];
          final realTokens = snapshot.data![2];

          final List<Marker> markers = [];

          // Helper function to create markers
          Marker createMarker({
            required dynamic matchingRealToken,
            required Color color,
          }) {
            final lat = double.tryParse(matchingRealToken['coordinate']['lat']);
            final lng = double.tryParse(matchingRealToken['coordinate']['lng']);

            if (lat != null && lng != null) {
              return Marker(
                point: LatLng(lat, lng),
                width: 80.0,
                height: 80.0,
                child: Icon(
                  Icons.location_on,
                  color: color,
                  size: 40.0,
                ),
                key: ValueKey(matchingRealToken), // Use key to store data
              );
            } else {
              return Marker(
                point: LatLng(0, 0),
                width: 0,
                height: 0,
                child: const SizedBox.shrink(),
              );
            }
          }

          // Add Wallet tokens to the map
          for (var walletToken in walletTokens) {
            final tokenAddress = walletToken['token']['address'].toLowerCase();

            final matchingRealToken = realTokens.firstWhere(
              (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
              orElse: () => null,
            );

            if (matchingRealToken != null && matchingRealToken['coordinate'] != null) {
              markers.add(
                createMarker(
                  matchingRealToken: matchingRealToken,
                  color: Colors.green,
                ),
              );
            }
          }

          // Add RMM tokens to the map
          for (var rmmToken in rmmTokens) {
            final tokenAddress = rmmToken['token']['id'].toLowerCase();

            final matchingRealToken = realTokens.firstWhere(
              (realToken) => realToken['uuid'].toLowerCase() == tokenAddress,
              orElse: () => null,
            );

            if (matchingRealToken != null && matchingRealToken['coordinate'] != null) {
              markers.add(
                createMarker(
                  matchingRealToken: matchingRealToken,
                  color: Colors.blue,
                ),
              );
            }
          }

          if (markers.isEmpty) {
            return const Center(child: Text('No matching tokens found on the map'));
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(42.367476, -83.130921),
              initialZoom: 10.0,
              onTap: (_, __) => _popupController.hideAllPopups(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              PopupScope(
                child: MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 70,
                    disableClusteringAtZoom: 15,
                    size: const Size(40, 40),
                    markers: markers,
                    builder: (context, markers) {
                      return CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(markers.length.toString()),
                      );
                    },
                    popupOptions: PopupOptions(
                      popupController: _popupController,
                      popupBuilder: (BuildContext context, Marker marker) {
                        final matchingRealToken = marker.key is ValueKey
                            ? (marker.key as ValueKey).value
                            : null;

                        if (matchingRealToken != null) {
                          return Card(
                            child: Container(
                              width: 200,
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    matchingRealToken['imageLink'][0],
                                    width: 200,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      matchingRealToken['shortName'],
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const Text('No data available for this marker');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
