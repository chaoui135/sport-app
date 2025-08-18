
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/auth_page.dart';
import 'pages/full_workout_plan_page.dart';
import 'pages/nutrition_page.dart';
import 'pages/goals_list_page.dart';
import 'pages/workout_page.dart';
import 'pages/boutique_page.dart';
import 'pages/club_search_page.dart';
import 'pages/mood_music_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return MaterialApp(
      title: 'FitVista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.indigoAccent,
        scaffoldBackgroundColor: Color(0xFFF7F8FC),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          foregroundColor: Colors.black87,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme).apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.indigoAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: AuthPage(),
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
      ClubSearchPage(),
      MoodMusicPage(),

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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Programme'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progression'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.sentiment_satisfied_alt), label: 'MoodMusic'),
        ],
      ),
    );
  }
}
