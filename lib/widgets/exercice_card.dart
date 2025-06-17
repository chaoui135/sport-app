// exercise_card.dart
import 'package:flutter/material.dart';

class ExerciseCardWithAddButton extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onAdd;
  final VoidCallback onToggleFavorite;

  const ExerciseCardWithAddButton({
    required this.exercise,
    required this.isSelected,
    required this.isFavorite,
    required this.onAdd,
    required this.onToggleFavorite,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise['name'] ?? 'Sans nom',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: onToggleFavorite,
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(exercise['name'] ?? 'Exercice'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exercise['instructions'] != null)
                                  Text("Instructions: ${exercise['instructions']}", style: TextStyle(fontSize: 14)),
                                if (exercise['muscle'] != null)
                                  Text("Muscle: ${exercise['muscle']}", style: TextStyle(fontSize: 14)),
                                if (exercise['equipment'] != null)
                                  Text("Équipement: ${exercise['equipment']}", style: TextStyle(fontSize: 14)),
                                if (exercise['difficulty'] != null)
                                  Text("Difficulté: ${exercise['difficulty']}", style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Fermer"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            Text("Type: ${exercise['type'] ?? 'N/A'}"),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.red : Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: Text(isSelected ? 'Retirer' : 'Ajouter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
