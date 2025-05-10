// /lib/pages/goals_list_page.dart
import 'package:flutter/material.dart';
import 'package:fitvista/models/goal.dart';
import 'package:fitvista/pages/add_goal_page.dart';
import 'package:fitvista/pages/progress_page.dart';

class GoalsListPage extends StatefulWidget {
  const GoalsListPage({Key? key}) : super(key: key);

  @override
  State<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends State<GoalsListPage> {
  List<Goal> userGoals = [];

  // Fonction pour ajouter un objectif à la liste
  void _addGoal(Goal goal) {
    setState(() {
      userGoals.add(goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Objectifs")),
      body: userGoals.isEmpty
          ? const Center(child: Text("Aucun objectif pour le moment."))
          : ListView.builder(
        itemCount: userGoals.length,
        itemBuilder: (context, index) {
          final goal = userGoals[index];
          return ListTile(
            title: Text(goal.title),
            subtitle: Text('${(goal.percentage * 100).toStringAsFixed(1)}% atteint'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressPage(goal: goal),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newGoal = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalPage()),
          );

          if (newGoal != null) {
            _addGoal(newGoal); // Ajouter l'objectif à la liste
          }
        },
      ),
    );
  }
}
