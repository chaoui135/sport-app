import 'package:fitvista/pages/club_search_page.dart';
import 'package:fitvista/pages/goals_list_page.dart';
import 'package:fitvista/pages/full_workout_plan_page.dart';
import 'package:flutter/material.dart';
import 'pages/boutique_page.dart';
import 'pages/nutrition_page.dart';
import 'pages/progress_page.dart';
import 'pages/workout_page.dart';
import 'pages/auth_page.dart';
import 'pages/full_workout_plan_page.dart';






void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitVista',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      FullWorkoutPlanPage(),
      NutritionPage(),
      GoalsListPage(),
      WorkoutPage(),
      AuthPage(),
      BoutiquePage(),
      PlaceMapPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitVista'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, color: Colors.black),
            label: 'Program',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_rounded, color: Colors.black),
            label: 'Nutrition',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart, color: Colors.black),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center, color: Colors.black),
            label: 'Workout',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            label: 'Boutique',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Colors.black),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
