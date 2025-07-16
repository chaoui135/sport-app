import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// --------------- Spoonacular API Service ---------------
class NutritionService {
  final String apiKey = '91f7622b5e59422fb84b2b29c6d0281f';

  Future<List<dynamic>> fetchRecipes({
    required int maxCalories,
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

  // ---------- Mealplanner (optionnel, nécessite API Pro) ----------
  Future<List<Map<String, dynamic>>> fetchDayPlan({required int targetCalories, String diet = ''}) async {
    final params = {
      'timeFrame': 'day',
      'targetCalories': '$targetCalories',
      'apiKey': apiKey,
    };
    if (diet.isNotEmpty && diet != 'all') params['diet'] = diet;

    final uri = Uri.https(
      'api.spoonacular.com',
      '/mealplanner/generate',
      params,
    );
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      return (data['meals'] as List).cast<Map<String, dynamic>>();
    }
    throw Exception('Échec du chargement plan : ${resp.statusCode}');
  }
}

// --------------- Notifications INIT ---------------
final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);
  await _notificationsPlugin.initialize(initSettings);
}

Future<void> scheduleDailyReminder() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'journal_channel', 'Journal Reminder',
    channelDescription: 'Rappel journal alimentaire quotidien',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails notifDetails = NotificationDetails(android: androidDetails);
  await _notificationsPlugin.periodicallyShow(
    0,
    'FitVista : Journal Nutrition',
    'N’oublie pas de remplir ton journal alimentaire aujourd’hui !',
    RepeatInterval.daily,
    notifDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

// --------------- Main Page ---------------
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
  String _imcCat = '';
  Color _imcColor = Colors.grey;

  // Recettes & journal
  final _service = NutritionService();
  final _maxCalCtl = TextEditingController(); // <-- Vide par défaut
  String _selectedDiet = 'all';
  bool _loading = false;
  List<dynamic> _recipes = [];
  List<Map<String, dynamic>> _journal = [];

  final diets = [
    {'label': 'Tous', 'value': 'all'},
    {'label': 'Healthy', 'value': 'healthy'},
    {'label': 'Végétarien', 'value': 'vegetarian'},
    {'label': 'Vegan', 'value': 'vegan'},
    {'label': 'Sans Gluten', 'value': 'gluten free'},
    {'label': 'Low Carb', 'value': 'low carb'},
  ];

  @override
  void initState() {
    super.initState();
    initNotifications();
    scheduleDailyReminder();
  }

  Future<void> _loadRecipes() async {
    final text = _maxCalCtl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saisis d'abord un objectif calories.")),
      );
      return;
    }
    final maxCal = int.tryParse(text);
    if (maxCal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Valeur calories invalide.")),
      );
      return;
    }
    setState(() => _loading = true);
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

  // Générer menu journalier, sans doublons, selon calories cibles
  Future<List<Map<String, dynamic>>> generateDayMenu(int cibleCal) async {
    final repartition = [
      {'repas': 'Petit-déjeuner', 'pourcent': 0.20},
      {'repas': 'Déjeuner', 'pourcent': 0.35},
      {'repas': 'Dîner', 'pourcent': 0.35},
      {'repas': 'Snack', 'pourcent': 0.10},
    ];
    List<Map<String, dynamic>> dayMenu = [];
    Set<int> usedIds = {};
    for (var r in repartition) {
      final maxCal = (cibleCal * (r['pourcent'] as double)).round();
      final recipes = await _service.fetchRecipes(
        maxCalories: maxCal,
        number: 8, // plus de choix pour éviter les doublons
        diet: _selectedDiet == 'all' ? '' : _selectedDiet,
      );
      final available = recipes.where((rec) => !usedIds.contains(rec['id'])).toList();
      if (available.isNotEmpty) {
        available.shuffle();
        final details = await _service.fetchRecipeDetails(available.first['id']);
        dayMenu.add({...details, 'repas': r['repas']});
        usedIds.add(available.first['id']);
      }
    }
    return dayMenu;
  }

  void _calculate() {
    final w = double.tryParse(_weightCtl.text);
    final h = double.tryParse(_heightCtl.text);
    final a = int.tryParse(_ageCtl.text);
    final act = double.tryParse(_activityCtl.text);

    if (w == null || w < 25 || w > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le poids doit être compris entre 25 et 200 kg.')),
      );
      return;
    }
    if (h == null || h < 100 || h > 220) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La taille doit être comprise entre 100 et 220 cm.')),
      );
      return;
    }
    if (a == null || a < 13 || a > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("L'âge doit être compris entre 13 et 99 ans.")),
      );
      return;
    }
    // Niveau d'activité (vérifie les valeurs acceptées)
    const List<double> niveauxAcceptes = [1.2, 1.375, 1.55, 1.725, 1.9];
    if (act == null || !niveauxAcceptes.contains(act)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Le niveau d'activité doit être l'une des valeurs suivantes : 1.2, 1.375, 1.55, 1.725, 1.9.")),
      );
      return;
    }

    // Calcul si tout est bon
    final bmi = w / ((h / 100) * (h / 100));
    final bmr = 10 * w + 6.25 * h - 5 * a + 5;
    setState(() {
      _bmi = bmi;
      _calNeeds = bmr * act; // act est non-null ici, plus d'erreur !
      if (_bmi! < 18.5) {
        _imcCat = "Maigreur";
        _imcColor = Colors.blue;
      } else if (_bmi! < 25) {
        _imcCat = "Normal";
        _imcColor = Colors.green;
      } else if (_bmi! < 30) {
        _imcCat = "Surpoids";
        _imcColor = Colors.orange;
      } else {
        _imcCat = "Obésité";
        _imcColor = Colors.red;
      }
    });
  }




  void _showActivityInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Niveaux d'activité"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1.2 : Sédentaire"),
            Text("1.375 : Légèrement actif"),
            Text("1.55 : Modérément actif"),
            Text("1.725 : Très actif"),
            Text("1.9 : Extrêmement actif"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
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
        'title': recipe['title'],
        'cal': cal,
        'prot': prot,
        'fat': fat,
        'carb': carb,
        'img': recipe['image'] ?? '',
      });
    });
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

  void _showJournal() {
    final t = _totals;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Journal Alimentaire',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
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
                        child: Image.network(e['img'],
                            width: 42, height: 42, fit: BoxFit.cover))
                        : null,
                    title: Text(e['title'],
                        maxLines: 1, overflow: TextOverflow.ellipsis),
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
            Text(
                "Total :  ${t['cal']!.toStringAsFixed(0)} kcal | ${t['prot']!.toStringAsFixed(1)}P / ${t['carb']!.toStringAsFixed(1)}G / ${t['fat']!.toStringAsFixed(1)}L"),
            SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Fermer')),
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), ...children]),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard('Calcul IMC & Besoins', [
                TextField(
                    controller: _weightCtl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Poids (kg)')),
                SizedBox(height: 5),
                TextField(
                    controller: _heightCtl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Taille (cm)')),
                SizedBox(height: 5),
                TextField(
                    controller: _ageCtl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Âge (ans)')),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _activityCtl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Niveau activité (1.2–1.9)'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.teal),
                      tooltip: "Aide: Niveaux d'activité",
                      onPressed: _showActivityInfo,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('CALCULER'),
                  ),
                ),
                if (_bmi != null)
                  Row(
                    children: [
                      Text('IMC : ${_bmi!.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Text(_imcCat, style: TextStyle(color: _imcColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                if (_calNeeds != null)
                  Text('Besoins cal/j : ${_calNeeds!.toStringAsFixed(0)}'),
              ]),

              _buildCard('Recettes Santé', [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _maxCalCtl,
                        decoration: InputDecoration(
                          labelText: "Calories (max par recette ou total du jour)",
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
                          .map((d) => DropdownMenuItem(
                          value: d['value'], child: Text(d['label']!)))
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.auto_awesome, color: Colors.white),
                      label: Text("Générer menu journalier"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () async {
                        final cible = int.tryParse(_maxCalCtl.text.trim() == "" ? "0" : _maxCalCtl.text.trim());
                        if (cible == null || cible <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Saisis d'abord un objectif calories.")),
                          );
                          return;
                        }
                        setState(() => _loading = true);
                        try {
                          final menu = await generateDayMenu(cible);
                          setState(() => _loading = false);

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Menu du jour (~${cible} kcal)'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: menu.map((r) => ListTile(
                                    leading: r['image'] != null ? Image.network(r['image'], width: 44) : null,
                                    title: Text('${r['repas']} : ${r['title']}'),
                                    subtitle: Text(
                                        'Calories: ${r['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Calories', orElse: () => {'amount': 0})['amount'] ?? '?'} kcal'
                                    ),
                                  )).toList(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Tout ajouter au journal'),
                                  onPressed: () {
                                    for (var r in menu) _addToJournal(r);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Menu ajouté au journal !'),
                                        backgroundColor: Colors.teal,
                                        duration: Duration(milliseconds: 1100),
                                      ),
                                    );
                                  },
                                ),
                                TextButton(child: Text('Fermer'), onPressed: () => Navigator.pop(context)),
                              ],
                            ),
                          );
                        } catch (e) {
                          setState(() => _loading = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Génère un menu (petit-déj, déjeuner, dîner, snack) pour atteindre ton objectif calories.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
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
                              onPressed: () async {
                                final details = await _service.fetchRecipeDetails(r['id']);
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(details['title']),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (details['image'] != null)
                                            Center(child: Image.network(details['image'], height: 130)),
                                          SizedBox(height: 10),
                                          Text(
                                            details['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '',
                                            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                                          ),
                                          SizedBox(height: 12),
                                          Text("Calories : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Calories', orElse: () => {'amount': 0})['amount'] ?? '?'} kcal"),
                                          Text("Protéines : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Protein', orElse: () => {'amount': 0})['amount'] ?? '?'} g"),
                                          Text("Glucides : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Carbohydrates', orElse: () => {'amount': 0})['amount'] ?? '?'} g"),
                                          Text("Lipides : ${details['nutrition']['nutrients']?.firstWhere((n) => n['name']=='Fat', orElse: () => {'amount': 0})['amount'] ?? '?'} g"),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer'))
                                    ],
                                  ),
                                );
                              },
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
