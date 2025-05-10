import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkoutApiService {
  final String apiKey = '64a02cde80msh5829fa8645dc066p180a1ajsnc1bfa29badf9';
  final String apiHost = 'ai-workout-planner-exercise-fitness-nutrition-guide.p.rapidapi.com';

  Future<Map<String, dynamic>> getCustomWorkoutPlan({
    required String goal,
    required String fitnessLevel,
    required List<String> preferences,
    required List<String> healthConditions,
    required int daysPerWeek,
    required int sessionDuration,
    required int planDurationWeeks,
    required String lang,
  }) async {
    final uri = Uri.parse(
      'https://$apiHost/generateWorkoutPlan?noqueue=1',
    );

    final response = await http.post(
      uri,
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': apiHost,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "goal": goal,
        "fitness_level": fitnessLevel,
        "preferences": preferences,
        "health_conditions": healthConditions,
        "schedule": {
          "days_per_week": daysPerWeek,
          "session_duration": sessionDuration,
        },
        "plan_duration_weeks": planDurationWeeks,
        "lang": lang
      }),
    );

    print("Request URI: $uri");
    print("Response (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur ${response.statusCode} : ${response.reasonPhrase}');
    }
  }
}
