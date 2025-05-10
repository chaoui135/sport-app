// lib/pages/nutrition_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NutritionService {
  final String apiKey = '91f7622b5e59422fb84b2b29c6d0281f';

  Future<List<dynamic>> fetchHealthyRecipes({
    int maxCalories = 500,
    int number = 10,
  }) async {
    final uri = Uri.https(
      'api.spoonacular.com',
      '/recipes/complexSearch',
      {
        'diet': 'healthy',
        'maxCalories': '$maxCalories',
        'number': '$number',
        'apiKey': apiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Échec du chargement : ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(int id) async {
    final uri = Uri.https(
      'api.spoonacular.com',
      '/recipes/$id/information',
      {
        'includeNutrition': 'true',
        'apiKey': apiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec du chargement : ${response.statusCode}');
    }
  }
}

class NutritionPage extends StatefulWidget {
  const NutritionPage({Key? key}) : super(key: key);

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  // Controllers pour IMC & objectifs
  final TextEditingController _weightCtl       = TextEditingController();
  final TextEditingController _heightCtl       = TextEditingController();
  final TextEditingController _ageCtl          = TextEditingController();
  final TextEditingController _activityCtl     = TextEditingController();
  final TextEditingController _goalWeightCtl   = TextEditingController();
  final TextEditingController _goalActivityCtl = TextEditingController();

  double? _bmi;
  double? _caloricNeeds;

  // Controllers pour recettes
  final TextEditingController _maxCalCtl = TextEditingController();
  bool _loading = true;
  List<dynamic> _recipes = [];
  List<Map<String, dynamic>> _journal = [];
  Timer? _timer;
  final NutritionService _service = NutritionService();

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _timer = Timer.periodic(const Duration(days: 1), (_) => _fetchRecipes());
  }

  Future<void> _fetchRecipes({int maxCal = 500}) async {
    setState(() => _loading = true);
    try {
      final list = await _service.fetchHealthyRecipes(maxCalories: maxCal);
      setState(() {
        _recipes = list;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _calculate() {
    final w = double.tryParse(_weightCtl.text);
    final h = double.tryParse(_heightCtl.text);
    final a = int.tryParse(_ageCtl.text);
    final act = double.tryParse(_activityCtl.text);
    if (w != null && h != null && a != null && act != null && h > 0) {
      final bmi = w / ((h / 100) * (h / 100));
      final bmr = 10 * w + 6.25 * h - 5 * a + 5;
      setState(() {
        _bmi = bmi;
        _caloricNeeds = bmr * act;
      });
    }
  }

  void _addToJournal(Map<String, dynamic> details) {
    final nutrients = details['nutrition']['nutrients'] as List;
    final cal  = (nutrients.firstWhere((n) => n['name']=='Calories')['amount']) as num;
    final prot = (nutrients.firstWhere((n) => n['name']=='Protein' )['amount']) as num;
    final fat  = (nutrients.firstWhere((n) => n['name']=='Fat'     )['amount']) as num;
    final carb = (nutrients.firstWhere((n) => n['name']=='Carbohydrates')['amount']) as num;
    setState(() {
      _journal.add({
        'title': details['title'],
        'cal': cal.toDouble(),
        'prot': prot.toDouble(),
        'fat': fat.toDouble(),
        'carb': carb.toDouble(),
      });
    });
  }

  Map<String,double> get _totals {
    double c=0, p=0, f=0, cb=0;
    for (var e in _journal) {
      c += e['cal'];
      p += e['prot'];
      f += e['fat'];
      cb+= e['carb'];
    }
    return {'cal':c,'prot':p,'fat':f,'carb':cb};
  }

  @override
  void dispose() {
    _timer?.cancel();
    _weightCtl.dispose(); _heightCtl.dispose();
    _ageCtl.dispose(); _activityCtl.dispose();
    _goalWeightCtl.dispose(); _goalActivityCtl.dispose();
    _maxCalCtl.dispose();
    super.dispose();
  }

  // Affiche le journal dans une pop‑up DataTable
  void _showJournalPopup() {
    final totals = _totals;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Journal Alimentaire'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('Aliment')),
                  DataColumn(label: Text('Cal')),
                  DataColumn(label: Text('P')),
                  DataColumn(label: Text('L')),
                  DataColumn(label: Text('G')),
                ],
                rows: _journal.map((e) {
                  return DataRow(cells: [
                    DataCell(Text(e['title'], overflow: TextOverflow.ellipsis)),
                    DataCell(Text(e['cal'].toStringAsFixed(1))),
                    DataCell(Text(e['prot'].toStringAsFixed(1))),
                    DataCell(Text(e['fat'].toStringAsFixed(1))),
                    DataCell(Text(e['carb'].toStringAsFixed(1))),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Totaux', style: Theme.of(ctx).textTheme.titleMedium),
              ),
              Text('Calories : ${totals['cal']!.toStringAsFixed(1)}'),
              Text('Protéines : ${totals['prot']!.toStringAsFixed(1)} g'),
              Text('Lipides : ${totals['fat']!.toStringAsFixed(1)} g'),
              Text('Glucides : ${totals['carb']!.toStringAsFixed(1)} g'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showActivityInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Niveaux d’activité',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _infoRow('1.2', 'Sédentaire'),
            _infoRow('1.375', 'Légèrement actif'),
            _infoRow('1.55', 'Modérément actif'),
            _infoRow('1.725', 'Très actif'),
            _infoRow('1.9', 'Extrêmement actif'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('FERMER', style: TextStyle(color: Colors.white70)),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String factor, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(factor, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    final tt = Theme.of(ctx).textTheme;
    final totals = _totals;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Nutrition & Santé', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            tooltip: 'Voir Journal',
            onPressed: _showJournalPopup,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showActivityInfo,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(ctx).padding.top,
            left: 16, right: 16, bottom: 16
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section IMC & Besoins
              Text('Calcul IMC & Besoins', style: tt.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInputCard('Vos Mesures', [
                _buildTextField('Poids (kg)', _weightCtl),
                _buildTextField('Taille (cm)', _heightCtl),
                _buildTextField('Âge (ans)', _ageCtl),
                _buildTextField('Niveau d’activité (1.2–1.9)', _activityCtl),
              ]),
              const SizedBox(height: 12),
              _buildInputCard('Vos Objectifs', [
                _buildTextField('Poids cible (kg)', _goalWeightCtl),
                _buildTextField('Activité cible (jours/semaine)', _goalActivityCtl),
              ]),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text('CALCULER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              if (_bmi != null || _caloricNeeds != null)
                _buildResultCard('Résultats', [
                  if (_bmi != null)
                    Text('IMC : ${_bmi!.toStringAsFixed(2)}', style: tt.titleMedium),
                  if (_caloricNeeds != null)
                    Text('Calories/j : ${_caloricNeeds!.toStringAsFixed(0)}', style: tt.titleMedium),
                ]),

              const SizedBox(height: 24),
              const Divider(color: Colors.white70),
              const SizedBox(height: 16),

              // Section Recettes
              Text('Recettes Santé', style: tt.headlineSmall?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _maxCalCtl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Max calories',
                  hintStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white12,
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) {
                  final m = int.tryParse(v) ?? 500;
                  _fetchRecipes(maxCal: m);
                },
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else
                ..._recipes.map((r) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        'https://spoonacular.com/recipeImages/${r['id']}-312x231.jpg',
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
                      ),
                      title: Text(r['title']),
                      onTap: () async {
                        final d = await _service.fetchRecipeDetails(r['id']);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(d['title']),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Image.network(d['image']),
                                  const SizedBox(height: 12),
                                  Text(d['summary'], style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
                            ],
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () async {
                          final d = await _service.fetchRecipeDetails(r['id']);
                          _addToJournal(d);
                        },
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 24),
              const Divider(color: Colors.white70),
              const SizedBox(height: 16),

              // Section Journal (affiché via pop‑up)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctl,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildInputCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white70,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ]),
      ),
    );
  }

  Widget _buildResultCard(String title, List<Widget> results) {
    return Card(
      color: Colors.white70,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...results.map((w) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: w)),
        ]),
      ),
    );
  }
}
