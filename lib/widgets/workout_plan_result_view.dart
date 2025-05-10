import 'package:flutter/material.dart';

class WorkoutPlanResultView extends StatelessWidget {
  final Map<String, dynamic> planData;

  const WorkoutPlanResultView({super.key, required this.planData});

  @override
  Widget build(BuildContext context) {
    final result = planData['result'] as Map<String, dynamic>?;

    if (result == null || result.isEmpty) {
      return Center(child: Text('Aucun plan reçu'));
    }

    return ElevatedButton(
      onPressed: () => _showWorkoutModal(context, result),
      child: Text('📋 Voir le plan d\'entraînement'),
    );
  }

  void _showWorkoutModal(BuildContext context, Map<String, dynamic> plan) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        final exercisesByDay = plan['exercises'] as List<dynamic>;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: scrollController,
              children: [
                Text("🎯 Objectif : ${plan['goal']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("👤 Niveau : ${plan['fitness_level']}"),
                Text("🗓️ Durée : ${plan['total_weeks']} semaines"),
                Text("📆 Séances/semaine : ${plan['schedule']['days_per_week']} | ⏱ ${plan['schedule']['session_duration']} min\n"),
                Divider(),

                ...exercisesByDay.map((dayBlock) {
                  final day = dayBlock['day'];
                  final exercises = dayBlock['exercises'] as List<dynamic>;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
                      leading: Icon(Icons.fitness_center, color: Colors.blue),
                      children: exercises.map<Widget>((ex) {
                        return ListTile(
                          leading: Icon(Icons.chevron_right, color: Colors.green),
                          title: Text(ex['name'] ?? 'Exercice'),
                          subtitle: Text(
                            "⏱ ${ex['duration'] ?? '-'} | 🔁 ${ex['repetitions'] ?? '-'} | 🌀 ${ex['sets'] ?? '-'} | 🧰 ${ex['equipment'] ?? '-'}",
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
