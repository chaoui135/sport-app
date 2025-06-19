import 'package:fitvista/pages/cart_page.dart';
import 'package:fitvista/pages/club_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

// Pages principales
import 'pages/auth_page.dart';
import 'pages/full_workout_plan_page.dart';
import 'pages/nutrition_page.dart';
import 'pages/goals_list_page.dart';
import 'pages/workout_page.dart';
import 'pages/boutique_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(FitnessApp());
}


class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitVista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.deepPurpleAccent),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: AuthPage(), // utilise la version stylisée
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
      BoutiquePage(),
      PlaceMapPage()
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitVista'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Program'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood_rounded), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Boutique'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
