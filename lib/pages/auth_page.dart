import 'package:fitvista/pages/club_search_page.dart';
import 'package:fitvista/pages/mood_music_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'full_workout_plan_page.dart';
import 'nutrition_page.dart';
import 'goals_list_page.dart';
import 'workout_page.dart';
import 'boutique_page.dart';
import 'club_search_page.dart';
import '../services/api_config.dart'; // adapte le chemin selon ton arborescence




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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Program'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood_rounded), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Boutique'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),

          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'MoodMusic'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}


class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _obscureText = true;
  String _userName = '';
  String _password = '';
  String _fullName = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleObscureText() => setState(() => _obscureText = !_obscureText);

  void _submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('${ApiConfig.baseUrl}/api/users/login');
      print('📡 Tentative de connexion vers : $url');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _userName,
            'password': _password,
          }),
        );

        print('🔁 Code HTTP: ${response.statusCode}');
        print('📥 Réponse brute: ${response.body}');

        // Vérifie que c’est bien du JSON
        if (!response.headers['content-type']!.contains('application/json')) {
          _showSnackBar('Erreur serveur : réponse non JSON');
          return;
        }

        if (response.statusCode == 200) {
          _showSnackBar('Connexion réussie !');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          final error = json.decode(response.body);
          _showSnackBar(error['message'] ?? 'Erreur de connexion');
        }
      } catch (error) {
        _showSnackBar('❌ Erreur réseau : $error');
      }
    }
  }

  void _submitAuthForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('${ApiConfig.baseUrl}/api/users/register');
      print('📡 Inscription vers : $url');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _userName,
            'password': _password,
            'fullName': _fullName,
          }),
        );

        print('🔁 Code HTTP: ${response.statusCode}');
        print('📥 Réponse brute: ${response.body}');

        if (!response.headers['content-type']!.contains('application/json')) {
          _showSnackBar('Erreur serveur : réponse non JSON');
          return;
        }

        if (response.statusCode == 201) {
          _showSnackBar('Inscription réussie !');
          setState(() => _isLogin = true);
        } else {
          final error = json.decode(response.body);
          _showSnackBar(error['message'] ?? "Erreur d'inscription");
        }
      } catch (error) {
        _showSnackBar('❌ Erreur réseau : $error');
      }
    }
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = theme.brightness == Brightness.dark
        ? [Color(0xFF141E30), Color(0xFF243B55)]
        : [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 70, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      _isLogin ? "Bienvenue 👋" : "Rejoins-nous 💪",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _isLogin ? "Connecte-toi pour continuer" : "Inscris-toi pour ton objectif",
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    SizedBox(height: 30),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey(_isLogin),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        padding: EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                decoration: _inputDecoration("Nom d'utilisateur"),
                                onSaved: (value) => _userName = value!.trim(),
                                validator: (value) =>
                                value == null || value.length < 4 ? 'Min 4 caractères' : null,
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                obscureText: _obscureText,
                                decoration: _inputDecoration('Mot de passe').copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.white54,
                                    ),
                                    onPressed: _toggleObscureText,
                                  ),
                                ),
                                onSaved: (value) => _password = value!,
                                validator: (value) =>
                                value == null || value.length < 6 ? 'Min 6 caractères' : null,
                              ),
                              if (!_isLogin) ...[
                                SizedBox(height: 15),
                                TextFormField(
                                  style: TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Nom complet'),
                                  onSaved: (value) => _fullName = value!,
                                  validator: (value) =>
                                  value == null || value.isEmpty ? 'Champ requis' : null,
                                ),
                              ],
                              SizedBox(height: 25),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurpleAccent,
                                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 60),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: _isLogin ? _submitLoginForm : _submitAuthForm,
                                child: Text(
                                  _isLogin ? 'Se connecter' : "S'inscrire",
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin ? "Créer un compte" : "J'ai déjà un compte",
                                  style: GoogleFonts.poppins(color: Colors.white70),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white),
      ),
      fillColor: Colors.white10,
      filled: true,
    );
  }
}