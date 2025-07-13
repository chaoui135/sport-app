import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ---- Service API Spoonacular ----
class NutritionService {
  final String apiKey = '91f7622b5e59422fb84b2b29c6d0281f';

  Future<List<dynamic>> fetchRecipes({
    int maxCalories = 600,
    int number = 8,
    String diet = '',
  }) async {
    final params = {
      'number': '$number',
      'apiKey': apiKey,
      'addRecipeNutrition': 'true',
      'maxCalories': '$maxCalories'
    };
    if (diet.isNotEmpty && diet != 'all') params['diet'] = diet;

    final uri = Uri.https(
      'api.spoonacular.com',
      '/recipes/complexSearch',
      params,
    );
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return json.decode(resp.body)['results'];
    }
    throw Exception('Échec du chargement : ${resp.statusCode}');
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
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return json.decode(resp.body);
    }
    throw Exception('Échec du chargement : ${resp.statusCode}');
  }
}

// ---- Page Nutrition ----
class NutritionPage extends StatefulWidget {
  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  // IMC & besoins
  final _weightCtl = TextEditingController();
  final _heightCtl = TextEditingController();
  final _ageCtl = TextEditingController();
  final _activityCtl = TextEditingController();
  double? _bmi;
  double? _calNeeds;

  // Recettes
  final _service = NutritionService();
  final _maxCalCtl = TextEditingController(text: "600");
  String _selectedDiet = 'all';
  bool _loading = true;
  List<dynamic> _recipes = [];
  List<Map<String, dynamic>> _journal = [];
  final _customNameCtl = TextEditingController();
  final _customCalCtl = TextEditingController();
  final _customProtCtl = TextEditingController();
  final _customFatCtl = TextEditingController();
  final _customCarbCtl = TextEditingController();

  final List<Map<String, String>> diets = [
    {'label': 'Tous', 'value': 'all'},
    {'label': 'Healthy', 'value': 'healthy'},
    {'label': 'Végétarien', 'value': 'vegetarian'},
    {'label': 'Vegan', 'value': 'vegan'},
    {'label': 'Sans Gluten', 'value': 'gluten free'},
    {'label': 'Low Carb', 'value': 'low carb'},
  ];

  // Suggestions produits
  final List<Map<String, String>> supplements = [
    {'name': "Whey protéine", 'desc': "Complément riche en protéines"},
    {'name': "BCAA", 'desc': "Acides aminés essentiels"},
    {'name': "Oméga 3", 'desc': "Bon pour le cœur et le cerveau"},
    {'name': "Barre protéinée", 'desc': "Snack rapide, riche en protéines"},
    {'name': "Vitamines D", 'desc': "Pour l’immunité et l’ossature"},
    {'name': "Magnésium", 'desc': "Réduit la fatigue"},
    {'name': "Pré-workout", 'desc': "Booste l’énergie avant séance"},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _loading = true);
    final maxCal = int.tryParse(_maxCalCtl.text) ?? 600;
    final diet = _selectedDiet == 'all' ? '' : _selectedDiet;
    try {
      final list = await _service.fetchRecipes(
        maxCalories: maxCal,
        diet: diet,
      );
      setState(() => _recipes = list);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
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
        _calNeeds = bmr * act;
      });
    }
  }

  void _addToJournal(Map<String, dynamic> recipe) {
    final nutr = recipe['nutrition']?['nutrients'] ?? [];
    double cal = 0, prot = 0, fat = 0, carb = 0;
    for (var n in nutr) {
      if (n['name'] == 'Calories') cal = n['amount']?.toDouble() ?? 0;
      if (n['name'] == 'Protein') prot = n['amount']?.toDouble() ?? 0;
      if (n['name'] == 'Fat') fat = n['amount']?.toDouble() ?? 0;
      if (n['name'] == 'Carbohydrates') carb = n['amount']?.toDouble() ?? 0;
    }
    setState(() {
      _journal.add({
        'title': recipe['title'] as String,
        'cal': cal,
        'prot': prot,
        'fat': fat,
        'carb': carb,
        'img': recipe['image'] ?? '',
      });
    });
  }

  void _addCustomToJournal() {
    final title = _customNameCtl.text.trim();
    final cal = double.tryParse(_customCalCtl.text) ?? 0;
    final prot = double.tryParse(_customProtCtl.text) ?? 0;
    final fat = double.tryParse(_customFatCtl.text) ?? 0;
    final carb = double.tryParse(_customCarbCtl.text) ?? 0;
    if (title.isNotEmpty) {
      setState(() {
        _journal.add({
          'title': title,
          'cal': cal,
          'prot': prot,
          'fat': fat,
          'carb': carb,
          'img': '',
        });
      });
      _customNameCtl.clear();
      _customCalCtl.clear();
      _customProtCtl.clear();
      _customFatCtl.clear();
      _customCarbCtl.clear();
      Navigator.pop(context);
    }
  }

  Map<String, double> get _totals {
    double c = 0, p = 0, f = 0, cb = 0;
    for (var e in _journal) {
      c += e['cal'] ?? 0;
      p += e['prot'] ?? 0;
      f += e['fat'] ?? 0;
      cb += e['carb'] ?? 0;
    }
    return {'cal': c, 'prot': p, 'fat': f, 'carb': cb};
  }

  void _showRecipeDetail(dynamic recipe) async {
    final details = await _service.fetchRecipeDetails(recipe['id']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (_, ctl) => SingleChildScrollView(
          controller: ctl,
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (details['image'] != null)
                Center(child: Image.network(details['image'], height: 160)),
              SizedBox(height: 12),
              Text(details['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 8),
              Text(
                (details['summary'] as String?)?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
              SizedBox(height: 18),
              Text("Calories : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Calories', orElse: () => {'amount': 0})['amount'] ?? '?'} kcal"),
              Text("Protéines : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Protein', orElse: () => {'amount': 0})['amount'] ?? '?'} g"),
              Text("Glucides : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Carbohydrates', orElse: () => {'amount': 0})['amount'] ?? '?'} g"),
              Text("Lipides : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Fat', orElse: () => {'amount': 0})['amount'] ?? '?'} g"),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.add_circle_outline),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white),
                  label: Text('Ajouter au journal'),
                  onPressed: () {
                    _addToJournal(details);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJournal() {
    final t = _totals;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Journal Alimentaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _journal.length,
                itemBuilder: (_, i) {
                  final e = _journal[i];
                  return ListTile(
                    leading: (e['img'] ?? '').isNotEmpty
                        ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(e['img'], width: 42, height: 42, fit: BoxFit.cover))
                        : null,
                    title: Text(e['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      "Kcal: ${e['cal']?.toStringAsFixed(0)}, P: ${e['prot']?.toStringAsFixed(1)}, G: ${e['carb']?.toStringAsFixed(1)}, L: ${e['fat']?.toStringAsFixed(1)}",
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[300]),
                      onPressed: () {
                        setState(() => _journal.removeAt(i));
                        Navigator.pop(context);
                        _showJournal();
                      },
                    ),
                  );
                },
              ),
            ),
            Divider(height: 20),
            Text("Total :  ${t['cal']!.toStringAsFixed(0)} kcal | ${t['prot']!.toStringAsFixed(1)}P / ${t['carb']!.toStringAsFixed(1)}G / ${t['fat']!.toStringAsFixed(1)}L"),
            SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Ajouter manuel (repas/supplément)"),
              onPressed: () {
                _showAddCustom();
              },
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
          ],
        ),
      ),
    );
  }

  void _showAddCustom() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ajout manuel"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _customNameCtl, decoration: InputDecoration(labelText: "Nom du repas/supplément")),
              TextField(controller: _customCalCtl, decoration: InputDecoration(labelText: "Calories"), keyboardType: TextInputType.number),
              TextField(controller: _customProtCtl, decoration: InputDecoration(labelText: "Protéines (g)"), keyboardType: TextInputType.number),
              TextField(controller: _customCarbCtl, decoration: InputDecoration(labelText: "Glucides (g)"), keyboardType: TextInputType.number),
              TextField(controller: _customFatCtl, decoration: InputDecoration(labelText: "Lipides (g)"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
          ElevatedButton(onPressed: _addCustomToJournal, child: Text("Ajouter"))
        ],
      ),
    );
  }

  void _showSupplements() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Suggestions de produits/suppléments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
            SizedBox(height: 16),
            ...supplements.map((s) => ListTile(
              leading: Icon(Icons.local_offer, color: Colors.teal[800]),
              title: Text(s['name']!),
              subtitle: Text(s['desc']!),
            )),
            SizedBox(height: 6),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Santé'),
        actions: [
          IconButton(icon: Icon(Icons.food_bank), onPressed: _showJournal),
          IconButton(icon: Icon(Icons.local_offer), onPressed: _showSupplements)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMC & besoins
              _buildCard('Calcul IMC & Besoins', [
                TextField(controller: _weightCtl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Poids (kg)')),
                SizedBox(height: 5),
                TextField(controller: _heightCtl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Taille (cm)')),
                SizedBox(height: 5),
                TextField(controller: _ageCtl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Âge (ans)')),
                SizedBox(height: 5),
                TextField(controller: _activityCtl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Niveau activité (1.2–1.9)')),
                SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('CALCULER'),
                  ),
                ),
                if (_bmi != null) Text('IMC : ${_bmi!.toStringAsFixed(2)}'),
                if (_calNeeds != null) Text('Besoins cal/j : ${_calNeeds!.toStringAsFixed(0)}'),
              ]),

              // Recherche recettes + filtres
              _buildCard('Recettes Santé', [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _maxCalCtl,
                        decoration: InputDecoration(
                          labelText: "Calories max",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.search),
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (_) => _loadRecipes(),
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedDiet,
                      items: diets
                          .map((d) => DropdownMenuItem<String>(
                        value: d['value'] as String,
                        child: Text(d['label'] as String),
                      ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedDiet = v);
                          _loadRecipes();
                        }
                      },
                      underline: SizedBox(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      tooltip: "Actualiser",
                      onPressed: _loadRecipes,
                    )
                  ],
                ),
                SizedBox(height: 10),
                _loading
                    ? Center(child: CircularProgressIndicator(color: Colors.teal))
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _recipes.length,
                  separatorBuilder: (_, __) => SizedBox(height: 9),
                  itemBuilder: (_, i) {
                    final r = _recipes[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.network(
                              r['image'] ?? '',
                              width: 54, height: 54, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 32)),
                        ),
                        title: Text(r['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          "Kcal: ${r['nutrition']?['nutrients']?.firstWhere((n) => n['name']=='Calories', orElse: ()=>{'amount': 0})['amount'] ?? '?'}",
                          style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.info_outline, color: Colors.teal[800]),
                              tooltip: "Voir détails",
                              onPressed: () => _showRecipeDetail(r),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.teal[700]),
                              tooltip: "Ajouter au journal",
                              onPressed: () async {
                                final details = await _service.fetchRecipeDetails(r['id']);
                                _addToJournal(details);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Ajouté au journal !'),
                                    backgroundColor: Colors.teal,
                                    duration: Duration(milliseconds: 900),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
