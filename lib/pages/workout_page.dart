import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gif/gif.dart';



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
  }

  Future<void> fetchApiExercises() async {
    final muscleGroups = [
      'abdominals', 'abductors', 'adductors', 'biceps', 'calves',
      'chest', 'forearms', 'glutes', 'hamstrings', 'lats',
      'lower_back', 'middle_back', 'neck', 'quadriceps', 'traps', 'triceps'
    ];

    for (var muscle in muscleGroups) {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/exercises?muscle=$muscle'),
        headers: {
          'X-Api-Key': 'GOpjaCbMBYCQfaFfm/hIzg==WSeS3AaOyVvYnbQV',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          allExercises.addAll((data as List).map((e) => {
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
  }

  Future<void> fetchDatabaseExercises() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/exercises'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          for (var item in data) {
            allExercises.add({
              'name': item['name'] ?? 'N/A',
              'type': item['type'] ?? 'N/A',
              'duration': item['duration'] ?? 'N/A',
              'description': item['description'] ?? 'N/A',
              'gifFileName': item['gifFileName'] ?? null, // Utilisez null si absent
              'source': 'db',
            });
          }
        }
      }
    } catch (error) {
      print('Erreur de connexion : $error');
    }
  }


  bool matchesSearchQuery(Map<String, dynamic> exercise) {
    final query = searchQuery.toLowerCase();
    return (exercise['name']?.toLowerCase().contains(query) ?? false) ||
        (exercise['type']?.toLowerCase().contains(query) ?? false) ||
        (exercise['muscle']?.toLowerCase().contains(query) ?? false) ||
        (exercise['equipment']?.toLowerCase().contains(query) ?? false) ||
        (exercise['difficulty']?.toLowerCase().contains(query) ?? false) ||
        (exercise['instructions']?.toLowerCase().contains(query) ?? false) ||
        (exercise['description']?.toLowerCase().contains(query) ?? false);

  }

  void updateSportsSuggestions(String query) {
    Set<String> suggestions = {};
    if (query.isNotEmpty) {
      // Filtrer les suggestions de sports
      suggestions.addAll(sportsList.where((sport) => sport.toLowerCase().contains(query)));
      // Filtrer les exercices
      allExercises.forEach((exercise) {
        if (exercise['type']?.toLowerCase().contains(query) ?? false) {
          suggestions.add(exercise['type']);
        }
      });
    }
    setState(() {
      sportsSuggestions = suggestions.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredExercises = allExercises.where(matchesSearchQuery).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout', style: TextStyle(fontFamily: 'Bebas Neue',fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF121212),
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFF1C1C1E), // Couleur de fond
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  updateSportsSuggestions(textEditingValue.text.toLowerCase());
                  return sportsSuggestions.where((sport) => sport.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  setState(() {
                    searchQuery = selection;
                  });
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                  textEditingController.text = searchQuery;
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Rechercher un exercice ou un sport...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  return ExerciseCardWithAddButton(
                    exercise: exercise,
                    isSelected: selectedExercises.contains(exercise),
                    onAdd: () {
                      setState(() {
                        if (selectedExercises.contains(exercise)) {
                          selectedExercises.remove(exercise);
                        } else {
                          selectedExercises.add(exercise);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF121212),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Séance d\'entraînement personnalisée',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return SingleChildScrollView(
                            child: ListBody(
                              children: selectedExercises.map((exercise) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: Icon(Icons.fitness_center, color: Colors.black),
                                    title: Text(
                                      exercise['name'],
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          selectedExercises.remove(exercise);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Fermer', style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Voir la séance d\'entraînement personnalisée'),
            ),
            if (searchQuery.isNotEmpty && filteredExercises.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Aucun exercice trouvé pour "$searchQuery"',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter un nouvel exercice ou autre
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF121212),
      ),
    );
  }
}

class ExerciseCardWithAddButton extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final bool isSelected;
  final VoidCallback onAdd;

  ExerciseCardWithAddButton({
    required this.exercise,
    this.isSelected = false,
    required this.onAdd,
  });

  @override
  _ExerciseCardWithAddButtonState createState() => _ExerciseCardWithAddButtonState();
}

// ... (autres parties de votre code)

// ... (autres parties de votre code)

class _ExerciseCardWithAddButtonState extends State<ExerciseCardWithAddButton> with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.repeat(min: 0, max: 48, period: Duration(milliseconds: 6000));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isSelected ? Colors.teal[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.exercise['name'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(widget.exercise['name']),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.exercise.containsKey('duration'))
                                Text('Durée: ${widget.exercise['duration']} minutes'),
                              if (widget.exercise.containsKey('description'))
                                Text('Description: ${widget.exercise['description']}'),
                              if (widget.exercise.containsKey('muscle'))
                                Text('Muscle: ${widget.exercise['muscle']}'),
                              if (widget.exercise.containsKey('equipment'))
                                Text('Equipment: ${widget.exercise['equipment']}'),
                              if (widget.exercise.containsKey('difficulty'))
                                Text('Difficulty: ${widget.exercise['difficulty']}'),
                              if (widget.exercise.containsKey('instructions'))
                                Text('Instructions: ${widget.exercise['instructions']}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text('Fermer'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Type: ${widget.exercise['type']}', style: TextStyle(fontSize: 14)),
            if (widget.exercise.containsKey('duration')) ...[
              Text('Durée: ${widget.exercise['duration']} minutes', style: TextStyle(fontSize: 14)),
              Text('Description: ${widget.exercise['description']}', style: TextStyle(fontSize: 14)),
            ] else ...[
              Text('Muscle: ${widget.exercise['muscle']}', style: TextStyle(fontSize: 14)),
              Text('Equipment: ${widget.exercise['equipment']}', style: TextStyle(fontSize: 14)),
              Text('Difficulty: ${widget.exercise['difficulty']}', style: TextStyle(fontSize: 14)),
              Text('Instructions: ${widget.exercise['instructions']}', style: TextStyle(fontSize: 14)),
            ],
            SizedBox(height: 16),
            // Ajout du Gif avec gestion des erreurs
            if (widget.exercise.containsKey('gifFileName') && widget.exercise['gifFileName'] != null)
              Container(
                height: 100,
                child: Image.asset(
                  'assets/${widget.exercise['gifFileName']}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text("Erreur de chargement du GIF", style: TextStyle(color: Colors.red)));
                  },
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isSelected ? Colors.red : Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: widget.onAdd,
              child: Text(widget.isSelected ? 'Retirer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

