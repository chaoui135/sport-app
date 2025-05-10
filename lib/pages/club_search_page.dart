import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class PlaceMapPage extends StatefulWidget {
  const PlaceMapPage({Key? key}) : super(key: key);

  @override
  State<PlaceMapPage> createState() => _PlaceMapPageState();
}

class _PlaceMapPageState extends State<PlaceMapPage> {
  static const LatLng _initialCenter = LatLng(43.2965, 5.3698);
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _places = [];

  String _escapeQuery(String input) {
    return input.replaceAllMapped(RegExp(r'[\"\\]'), (match) => '\\${match[0]}');
  }

  Future<void> _searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _places.clear());
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final safeQuery = _escapeQuery(q);

    // ✅ Requête enrichie
    final overpassQL = '''
[out:json][timeout:25];
(
  node["name"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  way ["name"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  relation["name"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  
  node["sport"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  node["leisure"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  node["amenity"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  
  node["brand"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  node["operator"~"$safeQuery",i](43.19,5.25,43.38,5.43);
  node["description"~"$safeQuery",i](43.19,5.25,43.38,5.43);
);
out center;
''';
;

    try {
      final resp = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'data=${Uri.encodeQueryComponent(overpassQL)}',
      );

      if (resp.statusCode != 200) {
        throw Exception('Erreur Overpass: ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List).cast<Map<String, dynamic>>();

      final results = elements.map((e) {
        final isNode = e['type'] == 'node';
        final lat = isNode ? e['lat'] : e['center']['lat'];
        final lon = isNode ? e['lon'] : e['center']['lon'];
        final tags = Map<String, dynamic>.from(e['tags'] ?? {});
        return {
          'name': tags['name'] ?? 'Sans nom',
          'lat': (lat as num).toDouble(),
          'lon': (lon as num).toDouble(),
          'tags': tags,
        };
      }).toList();

      setState(() {
        _places = results;
        _isLoading = false;
      });

      if (_places.isNotEmpty) {
        _mapController.move(
          LatLng(_places.first['lat'], _places.first['lon']),
          14,
        );
        _showResultsPopup();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showResultsPopup() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Résultats'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _places.length,
            itemBuilder: (_, i) {
              final p = _places[i];
              return ListTile(
                title: Text(p['name']),
                onTap: () {
                  Navigator.pop(context);
                  _mapController.move(
                    LatLng(p['lat'], p['lon']),
                    16,
                  );
                  _showPlaceDetail(p);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetail(Map<String, dynamic> place) {
    final tags = place['tags'] as Map<String, dynamic>;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(place['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Coordonnées : ${place['lat'].toStringAsFixed(5)}, ${place['lon'].toStringAsFixed(5)}'),
            const SizedBox(height: 12),
            ...tags.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${e.key}: ${e.value}'),
            )),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() => _places.map((p) {
    return Marker(
      width: 40,
      height: 40,
      point: LatLng(p['lat'], p['lon']),
      child: InkWell(
        onTap: () => _showPlaceDetail(p),
        child: const Icon(Icons.location_on, color: Colors.red, size: 36),
      ),
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte des clubs - Marseille')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: _initialCenter, zoom: 13),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchPlaces,
                decoration: InputDecoration(
                  hintText: 'Rechercher (club, sport, salle...)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _places.clear();
                        _error = null;
                        _isLoading = false;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          if (_error != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red[100],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _searchPlaces(_searchController.text),
        child: const Icon(Icons.search),
      ),
    );
  }
}
