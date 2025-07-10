import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ClubSearchPage extends StatefulWidget {
  const ClubSearchPage({Key? key}) : super(key: key);

  @override
  _ClubSearchPageState createState() => _ClubSearchPageState();
}

class _ClubSearchPageState extends State<ClubSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Bbox pour Marseille (west,north,east,south)
  // Approximativement 5.316°E → 43.45°N → 5.466°E → 43.30°N
  final String _viewbox = '5.316,43.45,5.466,43.30';

  List<Map<String, dynamic>> _places = [];
  List<Marker> _markers = [];
  String _selectedType = 'all';

  Future<void> _searchPlaces() async {
    final rawQuery = _searchController.text.trim();
    if (rawQuery.isEmpty) return;

    // Si on filtre Sport, on ajoute "sport" au texte de recherche
    final query = _selectedType == 'sport' ? '$rawQuery sport' : rawQuery;

    final uri = Uri.parse('https://nominatim.openstreetmap.org/search')
        .replace(queryParameters: {
      'format': 'json',
      'q': query,
      'limit': '20',
      'viewbox': _viewbox,
      'bounded': '1',
    });

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'Flutter/fitvista'},
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur ${response.statusCode}')),
      );
      return;
    }

    final List data = json.decode(response.body);
    setState(() {
      _places = List<Map<String, dynamic>>.from(data);
      _markers = _places.map<Marker>((place) {
        final lat = double.parse(place['lat'] as String);
        final lon = double.parse(place['lon'] as String);
        return Marker(
          width: 50,
          height: 50,
          point: LatLng(lat, lon),
          child: GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(place['display_name'] as String)),
            ),
            child: const Icon(Icons.location_on, size: 40, color: Colors.red),
          ),
        );
      }).toList();
    });

    if (_markers.isNotEmpty) {
      _mapController.move(_markers.first.point, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche de clubs à Marseille')),
      body: Column(
        children: [
          // Barre de recherche + filtre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _searchPlaces(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous')),
                    DropdownMenuItem(value: 'sport', child: Text('Sport')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchPlaces,
                  child: const Text('OK'),
                ),
              ],
            ),
          ),

          // Carte interactive centrée – Marseille ~ (43.2965, 5.3698)
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(43.2965, 5.3698),
                zoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fitvista',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),

          // Liste des résultats
          if (_places.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (ctx, i) {
                  final place = _places[i];
                  return ListTile(
                    title: Text(
                      place['display_name'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${place['class']}/${place['type']}'),
                    onTap: () {
                      final lat = double.parse(place['lat'] as String);
                      final lon = double.parse(place['lon'] as String);
                      _mapController.move(LatLng(lat, lon), 15);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
