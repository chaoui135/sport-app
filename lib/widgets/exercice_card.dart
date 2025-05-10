import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final String exerciseName;
  final Map<String, dynamic> exerciseDetails; // Détails de l'exercice

  ExerciseCard({required this.exerciseName, required this.exerciseDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          exerciseName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${exerciseDetails['type']}'),
            Text('Muscle: ${exerciseDetails['muscle']}'),
            Text('Equipment: ${exerciseDetails['equipment']}'),
            Text('Difficulty: ${exerciseDetails['difficulty']}'),
          ],
        ),
        onTap: () {
          // Afficher les instructions de l'exercice
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(exerciseName),
              content: Text(exerciseDetails['instructions']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}