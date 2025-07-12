import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gif/gif.dart';
import '../services/api_config.dart';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<Map<String, dynamic>> allExercises = [];
  String searchQuery = '';
  List<String> sportsSuggestions = [];
  List<String> sportsList = [
    'Yoga', 'Musculation', 'Cardio', 'Pilates', 'CrossFit',
    'Cyclisme', 'Natation', 'Lutte', 'Judo', 'MMA',
    'Boxe', 'Tennis', 'Foot', 'Course'
  ];
  List<Map<String, dynamic>> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    await fetchApiExercises();
    await fetchDatabaseExercises();
    setState(() {}); // rafraîchir après le chargement
  }

  Future<void> fetchApiExercises() async {
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
        final data = json.decode(resp.body) as List;
        allExercises.addAll(data.map((e) => {
          'name': e['name'],
          'type': e['type'],
          'muscle': e['muscle'],
          'equipment': e['equipment'],
          'difficulty': e['difficulty'],
          'instructions': e['instructions'],
          'source': 'api',
        }));
      }
    }
  }

  Future<void> fetchDatabaseExercises() async {
    try {
      final resp = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/api/exercises'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List;
        allExercises.addAll(data.map((item) => {
          'name': item['name'] ?? 'N/A',
          'type': item['type'] ?? 'N/A',
          'duration': item['duration'] ?? 'N/A',
          'description': item['description'] ?? 'N/A',
          'gifFileName': item['gifFileName'],
          'source': 'db',
        }));
      }
    } catch (_) {}
  }

  bool matchesSearchQuery(Map<String, dynamic> e) {
    final q = searchQuery.toLowerCase();
    return e.values.any((v) =>
    v is String && v.toLowerCase().contains(q));
  }

  void updateSportsSuggestions(String q) {
    final s = <String>{};
    if (q.isNotEmpty) {
      s.addAll(sportsList
          .where((sport) => sport.toLowerCase().contains(q)));
      for (var e in allExercises) {
        if ((e['type'] as String)
            .toLowerCase()
            .contains(q)) s.add(e['type']);
      }
    }
    setState(() => sportsSuggestions = s.toList());
  }

  void _showSessionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, ctl) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 12),
              Text('Ma séance personnalisée',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: ctl,
                  itemCount: selectedExercises.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[700]),
                  itemBuilder: (_, i) {
                    final ex = selectedExercises[i];
                    return ListTile(
                      leading: Icon(Icons.fitness_center,
                          color: Colors.white),
                      title: Text(ex['name'],
                          style: TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        color: Colors.redAccent,
                        onPressed: () {
                          setState(() {
                            selectedExercises.remove(ex);
                          });
                          Navigator.pop(context);
                          _showSessionSheet();
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check),
                label: Text('Fermer'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white70, backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = allExercises.where(matchesSearchQuery).toList();

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white!, Colors.grey!],
            ),
          ),
        ),
        title: Text('Workout',
            style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // → Barre de recherche stylée
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.grey[850],
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: Autocomplete<String>(
                optionsBuilder: (val) {
                  updateSportsSuggestions(val.text.toLowerCase());
                  return sportsSuggestions
                      .where((s) => s.toLowerCase().contains(val.text));
                },
                onSelected: (s) {
                  setState(() => searchQuery = s.toLowerCase());
                },
                fieldViewBuilder: (ctx, ctrl, focus, onSub) {
                  ctrl.text = searchQuery;
                  return TextField(
                    controller: ctrl,
                    focusNode: focus,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un exercice ou sport…',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      prefixIcon:
                      Icon(Icons.search, color: Colors.grey[400]),
                    ),
                    onChanged: (v) =>
                        setState(() => searchQuery = v.toLowerCase()),
                    onSubmitted: (_) => onSub(),
                  );
                },
              ),
            ),
          ),
          // → Liste des exercices
          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Text(
                'Aucun exercice trouvé',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final ex = filtered[i];
                final sel = selectedExercises.contains(ex);
                return Card(
                  color: sel ? Colors.white : Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    title: Text(
                      ex['name'],
                      style: TextStyle(
                        color: sel ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Type: ${ex['type']}',
                      style: TextStyle(
                          color: sel
                              ? Colors.grey[300]
                              : Colors.grey[400]),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        sel
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        color:
                        sel ? Colors.redAccent : Colors.grey
                      ),
                      onPressed: () {
                        setState(() {
                          sel
                              ? selectedExercises.remove(ex)
                              : selectedExercises.add(ex);
                        });
                      },
                    ),
                    onTap: () => setState(() {
                      sel
                          ? selectedExercises.remove(ex)
                          : selectedExercises.add(ex);
                    }),
                  ),
                );
              },
            ),
          ),
          // → Bouton de séance
          if (selectedExercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _showSessionSheet,
                icon: Icon(Icons.fitness_center),
                label:
                Text('Voir la séance (${selectedExercises.length})'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.tealAccent[700],
                  elevation: 6,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: selectedExercises.isEmpty
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.tealAccent[700],
        child: Icon(Icons.check, color: Colors.white70),
        onPressed: _showSessionSheet,
      ),
    );
  }
}
