// lib/pages/add_goal_page.dart
import 'package:flutter/material.dart';
import 'package:fitvista/models/goal.dart';
import 'package:fitvista/models/progress_entry.dart';
import 'package:fitvista/pages/goal_type.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({Key? key}) : super(key: key);

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _progressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  GoalType _selectedGoalType = GoalType.weightLoss; // Type d'objectif par défaut

  // Fonction pour créer un nouvel objectif
  void _createGoal() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text;
      final target = double.tryParse(_targetController.text) ?? 0;
      final progress = double.tryParse(_progressController.text) ?? 0;

      // Initialiser la carte de progrès pour une période de 30 jours
      Map<DateTime, ProgressEntry> dailyProgress = {};
      for (int i = 0; i < 30; i++) {
        dailyProgress[DateTime.now().add(Duration(days: i))] = ProgressEntry(
          value: 0, // Valeur initiale pour chaque jour
          date: DateTime.now().add(Duration(days: i)),
        );
      }

      // Création d'un nouvel objectif
      final newGoal = Goal(
        id: DateTime.now().toString(),
        type: _selectedGoalType,
        title: title,
        target: target,
        progress: progress,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        dailyProgress: dailyProgress,
      );

      Navigator.pop(context, newGoal); // Retourner l'objectif créé à la page précédente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un Objectif")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection du type d'objectif
              DropdownButtonFormField<GoalType>(
                value: _selectedGoalType,
                onChanged: (GoalType? newType) {
                  setState(() {
                    _selectedGoalType = newType!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Type d\'objectif'),
                items: GoalType.values.map((GoalType goalType) {
                  return DropdownMenuItem<GoalType>(
                    value: goalType,
                    child: Text(goalType.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Titre de l'objectif
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre de l\'objectif'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est obligatoire.';
                  }
                  return null;
                },
              ),

              // Cible de l'objectif
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedGoalType == GoalType.weightLoss
                      ? 'Poids cible (kg)'
                      : _selectedGoalType == GoalType.activity
                      ? 'Durée de l\'activité (en minutes)'
                      : 'Cible en nombre de pas ou calories',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La cible est obligatoire.';
                  }
                  final target = double.tryParse(value);
                  if (target == null || target <= 0) {
                    return 'Veuillez entrer un nombre valide pour la cible.';
                  }
                  return null;
                },
              ),

              // Progrès actuel
              TextFormField(
                controller: _progressController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedGoalType == GoalType.weightLoss
                      ? 'Poids actuel (kg)'
                      : _selectedGoalType == GoalType.activity
                      ? 'Durée d\'activité réalisée (en minutes)'
                      : 'Progrès (en nombre de pas ou calories)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le progrès est obligatoire.';
                  }
                  final progress = double.tryParse(value);
                  if (progress == null || progress < 0) {
                    return 'Veuillez entrer un nombre valide pour le progrès.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createGoal,
                child: const Text('Créer l\'objectif'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
