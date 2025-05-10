import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        duration: Duration(seconds: 3), // Durée d'affichage
        behavior: SnackBarBehavior.floating, // Position flottante
        margin: EdgeInsets.all(16), // Marge autour du SnackBar
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
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
