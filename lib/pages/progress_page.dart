// lib/pages/progress_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitvista/models/goal.dart';
import 'package:fitvista/models/progress_entry.dart';

import 'goal_type.dart';

class ProgressPage extends StatelessWidget {
  final Goal goal;

  const ProgressPage({required this.goal, Key? key}) : super(key: key);

  void _showProgressInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Comment sont calculés vos progrès ?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Les progrès sont calculés selon l'objectif choisi."),
                const SizedBox(height: 10),
                if (goal.type == GoalType.weightLoss)
                  const Text(
                      "1. **Perte de poids** : Le graphique montre la perte de poids sur une période. La progression est calculée en fonction de la différence entre le poids cible et le poids actuel."),
                if (goal.type == GoalType.muscleGain)
                  const Text(
                      "2. **Prise de masse** : Le graphique montre l'augmentation de votre poids corporel. La progression est calculée de la même manière."),
                if (goal.type == GoalType.caloriesBurned)
                  const Text(
                      "3. **Calories brûlées** : Le graphique suit le nombre de calories brûlées, en fonction de votre activité."),
                if (goal.type == GoalType.custom)
                  const Text(
                      "4. **Objectif personnalisé** : Vous pouvez suivre toute autre donnée, comme les pas effectués ou les minutes d'exercice."),
                const SizedBox(height: 10),
                const Text(
                    "Les pourcentages sont calculés en divisant la progression actuelle par l'objectif total. Le graphique montre l'évolution au fil du temps."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double percentage = goal.percentage;

    // Extraire les données de progression
    List<double> progressValues = goal.dailyProgress.entries
        .map((entry) => entry.value.value) // Extraire les valeurs des ProgressEntry
        .toList();

    // Créer les groupes de barres pour le graphique
    final barGroups = List.generate(progressValues.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: progressValues[i], // Utiliser directement la valeur ici
            color: Colors.green,
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showProgressInfo(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: percentage,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 8),
                Text("${(percentage * 100).toStringAsFixed(1)}% atteint"),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: Text('Progression'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              return Text(
                                "${value.toStringAsFixed(0)}${goal.type == GoalType.caloriesBurned ? " cal" : " kg"}",
                                style: TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: Text('Jour'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              return Text("J${value.toInt() + 1}");
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
