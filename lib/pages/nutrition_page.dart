// lib/pages/nutrition_page.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class NutritionPage extends StatefulWidget {
  const NutritionPage({Key? key}) : super(key: key);

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  // controllers IMC
  final _weightCtl       = TextEditingController();
  final _heightCtl       = TextEditingController();
  final _ageCtl          = TextEditingController();
  final _activityCtl     = TextEditingController();
  final _goalWeightCtl   = TextEditingController();
  final _goalActivityCtl = TextEditingController();

  double? _bmi;
  double? _calNeeds;

  // recettes
  final _maxCalCtl = TextEditingController();
  bool _loading    = true;
  List<dynamic> _recipes = [];
  List<Map<String, dynamic>> _journal = [];
  Timer? _timer;
  final _service = NutritionService();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    // rafraîchir chaque jour
    _timer = Timer.periodic(const Duration(days: 1), (_) => _loadRecipes());
  }

  Future<void> _loadRecipes({int maxCal = 500}) async {
    setState(() => _loading = true);
    try {
      final list = await _service.fetchHealthyRecipes(maxCalories: maxCal);
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
    final w   = double.tryParse(_weightCtl.text);
    final h   = double.tryParse(_heightCtl.text);
    final a   = int.tryParse(_ageCtl.text);
    final act = double.tryParse(_activityCtl.text);
    if (w != null && h != null && a != null && act != null && h > 0) {
      final bmi = w / ((h/100)*(h/100));
      final bmr = 10*w + 6.25*h - 5*a + 5;
      setState(() {
        _bmi     = bmi;
        _calNeeds = bmr * act;
      });
    }
  }

  void _addToJournal(Map<String, dynamic> d) {
    final nutrients = d['nutrition']['nutrients'] as List;
    final cal  = nutrients.firstWhere((n) => n['name']=='Calories')['amount'] as num;
    final prot = nutrients.firstWhere((n) => n['name']=='Protein' )['amount'] as num;
    final fat  = nutrients.firstWhere((n) => n['name']=='Fat'     )['amount'] as num;
    final carb = nutrients.firstWhere((n) => n['name']=='Carbohydrates')['amount'] as num;
    setState(() {
      _journal.add({
        'title': d['title'],
        'cal': cal.toDouble(),
        'prot': prot.toDouble(),
        'fat': fat.toDouble(),
        'carb': carb.toDouble(),
      });
    });
  }

  Map<String,double> get _totals {
    double c=0,p=0,f=0,cb=0;
    for (var e in _journal) {
      c+=e['cal']; p+=e['prot']; f+=e['fat']; cb+=e['carb'];
    }
    return {'cal':c,'prot':p,'fat':f,'carb':cb};
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final ctl in [
      _weightCtl,_heightCtl,_ageCtl,_activityCtl,
      _goalWeightCtl,_goalActivityCtl,_maxCalCtl
    ]) {
      ctl.dispose();
    }
    super.dispose();
  }

  void _showJournal() {
    final t = _totals;
    showDialog(
      context: context,
      builder: (ctx)=> AlertDialog(
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
                rows: _journal.map((e){
                  return DataRow(cells:[
                    DataCell(Text(e['title'], overflow: TextOverflow.ellipsis)),
                    DataCell(Text(e['cal'].toStringAsFixed(1))),
                    DataCell(Text(e['prot'].toStringAsFixed(1))),
                    DataCell(Text(e['fat'].toStringAsFixed(1))),
                    DataCell(Text(e['carb'].toStringAsFixed(1))),
                  ]);
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text('Totaux :',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('Calories : ${t['cal']!.toStringAsFixed(1)}'),
              Text('Protéines : ${t['prot']!.toStringAsFixed(1)} g'),
              Text('Lipides : ${t['fat']!.toStringAsFixed(1)} g'),
              Text('Glucides : ${t['carb']!.toStringAsFixed(1)} g'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Fermer')),
        ],
      ),
    );
  }

  void _showActivityInfo() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Niveaux d’activité', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...[
              ['1.2','Sédentaire'],
              ['1.375','Légèrement actif'],
              ['1.55','Modérément actif'],
              ['1.725','Très actif'],
              ['1.9','Extrêmement actif'],
            ].map((row)=> Padding(
              padding: const EdgeInsets.symmetric(vertical:4),
              child: Row(
                children: [
                  Text(row[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width:12),
                  Text(row[1]),
                ],
              ),
            )),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Fermer'))
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctl){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:6),
      child: TextField(
        controller: ctl,
        keyboardType: TextInputType.numberWithOptions(decimal:true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children){
    return Card(
      margin: const EdgeInsets.symmetric(vertical:8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height:8),
          ...children
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final primary = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition & Santé'),
        actions: [
          IconButton(icon: const Icon(Icons.list_alt), onPressed: _showJournal),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: _showActivityInfo),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16, vertical:12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              // IMC & besoins
              _buildCard('Calcul IMC & Besoins', [
                _buildField('Poids (kg)', _weightCtl),
                _buildField('Taille (cm)', _heightCtl),
                _buildField('Âge (ans)', _ageCtl),
                _buildField('Niveau activité (1.2–1.9)', _activityCtl),
                const SizedBox(height:12),
                Center(
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(backgroundColor: primary),
                    child: const Text('CALCULER'),
                  ),
                ),
                if (_bmi != null)   Text('IMC : ${_bmi!.toStringAsFixed(2)}'),
                if (_calNeeds != null) Text('Besoins cal/j : ${_calNeeds!.toStringAsFixed(0)}'),
              ]),

              // Recettes
              _buildCard('Recettes Santé', [
                TextField(
                  controller: _maxCalCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max calories',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (v){
                    final m = int.tryParse(v) ?? 500;
                    _loadRecipes(maxCal: m);
                  },
                ),
                const SizedBox(height:8),
                if (_loading)
                  Center(child: CircularProgressIndicator(color: primary))
                else ..._recipes.map((r)=> Card(
                  elevation:1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.symmetric(vertical:4),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                          'https://spoonacular.com/recipeImages/${r['id']}-240x150.jpg',
                          width: 60, height:60, fit: BoxFit.cover,
                          errorBuilder:(_,__,___)=>const Icon(Icons.broken_image)
                      ),
                    ),
                    title: Text(r['title'], maxLines:1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: Icon(Icons.add_circle, color: primary),
                      onPressed: () async {
                        final d = await _service.fetchRecipeDetails(r['id']);
                        _addToJournal(d);
                      },
                    ),
                    onTap: () async {
                      final d = await _service.fetchRecipeDetails(r['id']);
                      showDialog(
                        context: ctx,
                        builder: (_) => AlertDialog(
                          title: Text(d['title']),
                          content: SingleChildScrollView(
                            child: Column(children:[
                              Image.network(d['image']),
                              const SizedBox(height:12),
                              Text(d['summary'], style: theme.textTheme.bodyMedium)
                            ]),
                          ),
                          actions:[
                            TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Fermer'))
                          ],
                        ),
                      );
                    },
                  ),
                )).toList(),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
