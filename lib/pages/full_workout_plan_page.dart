import 'package:flutter/material.dart';
import '../services/workout_api_service.dart';
import '../widgets/workout_plan_result_view.dart';

class FullWorkoutPlanPage extends StatefulWidget {
  @override
  _FullWorkoutPlanPageState createState() => _FullWorkoutPlanPageState();
}

class _FullWorkoutPlanPageState extends State<FullWorkoutPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final apiService = WorkoutApiService();

  String goal = 'Build muscle';
  String fitnessLevel = 'Beginner';
  List<String> preferences = [];
  List<String> healthConditions = ['None'];
  int daysPerWeek = 3;
  int sessionDuration = 45;
  int durationWeeks = 4;
  String lang = 'en';

  bool isLoading = false;
  Map<String, dynamic>? planData;

  final availableGoals = ['Build muscle', 'Lose weight', 'Gain strength'];
  final availableLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final availablePreferences = ['Cardio', 'Weight training', 'Stretching'];

  Future<void> generatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      planData = null;
    });

    try {
      final response = await apiService.getCustomWorkoutPlan(
        goal: goal,
        fitnessLevel: fitnessLevel,
        preferences: preferences,
        healthConditions: healthConditions,
        daysPerWeek: daysPerWeek,
        sessionDuration: sessionDuration,
        planDurationWeeks: durationWeeks,
        lang: lang,
      );

      setState(() => planData = response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create my personalized program')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField(
                value: goal,
                items: availableGoals.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => goal = val!),
                decoration: InputDecoration(labelText: "Objectif"),
              ),
              DropdownButtonFormField(
                value: fitnessLevel,
                items: availableLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) => setState(() => fitnessLevel = val!),
                decoration: InputDecoration(labelText: "Niveau"),
              ),
              Wrap(
                spacing: 8.0,
                children: availablePreferences.map((pref) => FilterChip(
                  label: Text(pref),
                  selected: preferences.contains(pref),
                  onSelected: (selected) => setState(() {
                    selected ? preferences.add(pref) : preferences.remove(pref);
                  }),
                )).toList(),
              ),
              TextFormField(
                initialValue: daysPerWeek.toString(),
                decoration: InputDecoration(labelText: "Jours par semaine"),
                keyboardType: TextInputType.number,
                onChanged: (val) => daysPerWeek = int.tryParse(val) ?? 3,
              ),
              TextFormField(
                initialValue: sessionDuration.toString(),
                decoration: InputDecoration(labelText: "Durée par séance (min)"),
                keyboardType: TextInputType.number,
                onChanged: (val) => sessionDuration = int.tryParse(val) ?? 45,
              ),
              TextFormField(
                initialValue: durationWeeks.toString(),
                decoration: InputDecoration(labelText: "Durée du programme (semaines)"),
                keyboardType: TextInputType.number,
                onChanged: (val) => durationWeeks = int.tryParse(val) ?? 4,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: generatePlan,
                child: Text("Générer le plan"),
              ),
              SizedBox(height: 20),
              if (isLoading)
                Center(child: CircularProgressIndicator()),
              if (planData != null)
                WorkoutPlanResultView(planData: planData!),
            ],
          ),
        ),
      ),
    );
  }
}
