import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class WorkoutPage extends StatefulWidget {
  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _selected = [];
  String _search = '';
  final List<String> _sportsList = [
    'Yoga', 'Musculation', 'Cardio', 'Pilates', 'CrossFit',
    'Cyclisme', 'Natation', 'Lutte', 'Judo', 'MMA',
    'Boxe', 'Tennis', 'Foot', 'Course'
  ];
  final Set<String> _filters = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllExercises();
  }

  Future<void> _fetchAllExercises() async {
    setState(() => _loading = true);
    List<Map<String, dynamic>> temp = [];

    // 1. API externe
    final muscleGroups = [
      'abdominals', 'abductors', 'adductors', 'biceps', 'calves',
      'chest', 'forearms', 'glutes', 'hamstrings', 'lats',
      'lower_back', 'middle_back', 'neck', 'quadriceps', 'traps', 'triceps'
    ];
    for (var muscle in muscleGroups) {
      final resp = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/exercises?muscle=$muscle'),
        headers: {'X-Api-Key': 'GOpjaCbMBYCQfaFfm/hIzg==WSeS3AaOyVvYnbQV'},
      );
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        temp.addAll(data.map<Map<String, dynamic>>((e) => {
          'name': (e['name'] ?? '').toString(),
          'type': (e['type'] ?? '').toString(),
          'muscle': (e['muscle'] ?? '').toString(),
          'equipment': (e['equipment'] ?? '').toString(),
          'difficulty': (e['difficulty'] ?? '').toString(),
          'description': (e['instructions'] ?? '').toString(),
          'gifFileName': null,
          'source': 'api',
        }));
      }
    }

    // 2. MongoDB Atlas (API Render)
    try {
      final resp = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/exercises'));
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        temp.addAll(data.map<Map<String, dynamic>>((e) => {
          'name': (e['name'] ?? '').toString(),
          'type': (e['type'] ?? '').toString(),
          'muscle': (e['muscle'] ?? '').toString(),
          'equipment': (e['equipment'] ?? '').toString(),
          'difficulty': (e['difficulty'] ?? '').toString(),
          'description': (e['description'] ?? '').toString(),
          'gifFileName': (e['gifFileName'] ?? '').toString(),
          'source': 'db',
        }));
      }
    } catch (e) {
      print("Erreur fetch Mongo Atlas/Render: $e");
    }

    setState(() {
      _all = temp;
      _filtered = temp;
      _loading = false;
      _selected.clear();
    });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _all.where((e) {
        final name = (e['name'] ?? '').toString().toLowerCase();
        final type = (e['type'] ?? '').toString().toLowerCase();
        final desc = (e['description'] ?? '').toString().toLowerCase();
        final muscle = (e['muscle'] ?? '').toString().toLowerCase();
        final matchSearch =
            name.contains(_search) ||
                type.contains(_search) ||
                desc.contains(_search) ||
                muscle.contains(_search);
        final matchSport =
            _filters.isEmpty ||
                _filters.any((f) => (e['type'] ?? '').toString().toLowerCase() == f.toLowerCase());
        return matchSearch && matchSport;
      }).toList();
    });
  }

  void _onSearchChanged(String v) {
    _search = v.toLowerCase();
    _applyFilter();
  }

  void _toggleSport(String sport) {
    setState(() {
      if (_filters.contains(sport)) _filters.remove(sport);
      else _filters.add(sport);
      _applyFilter();
    });
  }

  void _toggleSelected(Map<String, dynamic> ex) {
    setState(() {
      if (_selected.contains(ex)) {
        _selected.remove(ex);
      } else {
        _selected.add(ex);
      }
    });
  }

  void _showSessionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38, height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Ma séance (${_selected.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.teal[800],
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 12),
              if (_selected.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 18),
                  child: Text('Aucun exercice sélectionné',
                      style: TextStyle(color: Colors.grey[500])),
                ),
              if (_selected.isNotEmpty)
                ..._selected.map((ex) => Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: (ex['gifFileName'] ?? '').toString().isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiConfig.baseUrl}/gifs/${ex['gifFileName']}',
                        width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                        : Icon(Icons.fitness_center, color: Colors.teal, size: 30),
                    title: Text(ex['name'], style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(ex['type'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() {
                        _selected.remove(ex);
                        Navigator.pop(context);
                        _showSessionSheet();
                      }),
                    ),
                  ),
                )),
              if (_selected.isNotEmpty) SizedBox(height: 6),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Fermer', style: TextStyle(fontSize: 15)),
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Workout', style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.teal[900]),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: TextField(
              onChanged: _onSearchChanged,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice ou sport…',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 18),
              ),
            ),
          ),
          // Filtres par sport/type
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sportsList.map((sport) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FilterChip(
                    label: Text(sport, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    selected: _filters.contains(sport),
                    onSelected: (_) => _toggleSport(sport),
                    selectedColor: Colors.teal[100],
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.teal,
                    labelStyle: TextStyle(
                        color: _filters.contains(sport)
                            ? Colors.teal[900]
                            : Colors.black87
                    ),
                    shape: StadiumBorder(
                        side: BorderSide(color: Colors.teal.shade100)),
                  ),
                )).toList(),
              ),
            ),
          ),
          SizedBox(height: 6),
          // Liste des exercices fusionnée
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('Aucun exercice trouvé', style: TextStyle(color: Colors.grey[500])))
                : ListView.builder(
              itemCount: _filtered.length,
              padding: EdgeInsets.only(bottom: 96), // Pour bouton fixe
              itemBuilder: (_, i) {
                final ex = _filtered[i];
                final selected = _selected.contains(ex);
                return Card(
                  color: selected ? Colors.teal[50] : Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: selected ? 6 : 2,
                  child: ListTile(
                    leading: (ex['gifFileName'] ?? '').toString().isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiConfig.baseUrl}/gifs/${ex['gifFileName']}',
                        width: 65, height: 65, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, color: Colors.grey),
                      ),
                    )
                        : Icon(Icons.fitness_center, color: Colors.teal, size: 38),
                    title: Text(
                      ex['name'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: selected ? Colors.teal[900] : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((ex['type'] ?? '').toString().isNotEmpty)
                          Text("Type: ${ex['type']}", style: TextStyle(fontSize: 13)),
                        if ((ex['muscle'] ?? '').toString().isNotEmpty)
                          Text("Muscle: ${ex['muscle']}", style: TextStyle(fontSize: 13)),
                        if ((ex['description'] ?? '').toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              ex['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        selected ? Icons.check_circle : Icons.add_circle_outline,
                        color: selected ? Colors.teal : Colors.teal[200],
                        size: 28,
                      ),
                      onPressed: () => _toggleSelected(ex),
                      tooltip: selected
                          ? 'Retirer de ma séance'
                          : 'Ajouter à ma séance',
                    ),
                    onTap: () => _toggleSelected(ex),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selected.isNotEmpty
          ? SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(24, 6, 24, 16),
          child: ElevatedButton.icon(
            icon: Icon(Icons.fitness_center, size: 22),
            label: Text('Voir ma séance (${_selected.length})', style: TextStyle(fontSize: 17)),
            onPressed: _showSessionSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[700],
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      )
          : null,
    );
  }
}
