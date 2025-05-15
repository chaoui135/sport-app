import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importer les pages nécessaires
import 'pages/auth_page.dart';
import 'pages/full_workout_plan_page.dart';
import 'pages/nutrition_page.dart';
import 'pages/goals_list_page.dart';
import 'pages/workout_page.dart';
import 'pages/boutique_page.dart';

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
      home: AuthPage(), // Utiliser AuthPage comme écran d'accueil
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _obscureText = true;
  String _userName = '';
  String _password = '';
  String _fullName = '';

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _submitAuthForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('http://10.0.2.2:3000/api/users/register');

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

        if (response.statusCode == 201) {
          _showSnackBar('Inscription réussie !');
          setState(() => _isLogin = true); // Retour à l'écran de connexion
        } else {
          final errorMsg = json.decode(response.body)['message'] ?? "Erreur d'inscription";
          _showSnackBar(errorMsg);
        }
      } catch (error) {
        _showSnackBar('Erreur de connexion: $error');
      }
    }
  }

  void _submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('http://10.0.2.2:3000/api/users/login');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userName': _userName,
            'password': _password,
          }),
        );

        if (response.statusCode == 200) {
          _showSnackBar('Connexion réussie !');
          // Rediriger vers HomePage après la connexion
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          final errorMsg = json.decode(response.body)['message'] ?? 'Erreur de connexion';
          _showSnackBar(errorMsg);
        }
      } catch (error) {
        _showSnackBar('Erreur réseau: $error');
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
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Connexion' : 'Inscription')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Nom d'utilisateur"),
                onSaved: (value) => _userName = value!.trim(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
                  if (value.length < 4) return 'Minimum 4 caractères';
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: _toggleObscureText,
                  ),
                ),
                obscureText: _obscureText,
                onSaved: (value) => _password = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
                  if (value.length < 6) return 'Minimum 6 caractères';
                  return null;
                },
              ),
              if (!_isLogin)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nom complet'),
                  onSaved: (value) => _fullName = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
                    return null;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLogin ? _submitLoginForm : _submitAuthForm,
                child: Text(_isLogin ? 'Se connecter' : "S'inscrire"),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? "Créer un compte" : "J'ai déjà un compte"),
              ),
            ],
          ),
        ),
      ),
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
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Rediriger vers AuthPage pour déconnexion
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
            onPressed: _logout, // Appeler la méthode de déconnexion
          ),
        ],
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
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            label: 'Boutique',
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
