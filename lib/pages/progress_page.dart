// lib/pages/progress_page.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../models/progress_entry.dart';
import 'goal_type.dart';

class ProgressPage extends StatefulWidget {
  final Goal goal;
  const ProgressPage({required this.goal, Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _valueController = TextEditingController();

  /// Enregistre une nouvelle mesure horodatée.
  void _saveTodayValue() {
    final v = double.tryParse(_valueController.text);
    if (v == null) return;
    final now = DateTime.now();
    setState(() {
      widget.goal.dailyProgress[now] = ProgressEntry(date: now, value: v);
    });
    _valueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final goal      = widget.goal;
    final pct       = (goal.percentage * 100).clamp(0.0, 100.0);
    final unit      = goal.type == GoalType.caloriesBurned ? ' kcal' : ' kg';
    final mainColor = Theme.of(context).primaryColor;

    // 1) Tri et extraction des entrées
    final entries = goal.dailyProgress.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 2) Calcul du max pour l'échelle (évite un maxY à 0)
    final rawMax = entries.isNotEmpty
        ? entries.map((e) => e.value).reduce(max)
        : 1.0;
    final maxVal = (rawMax > 0 ? rawMax : 1.0) * 1.2;

    // 3) Création des barGroups
    final barGroups = List<BarChartGroupData>.generate(
      entries.length,
          (i) => BarChartGroupData(
        x: i,
        barsSpace: 8,
        barRods: [
          BarChartRodData(
            toY: entries[i].value,
            width: 20,
            borderRadius: BorderRadius.circular(6),
            color: mainColor,
          ),
        ],
      ),
    );

    // 4) Détermination du pas d'affichage des labels X
    final int maxLabels = 6;
    final int labelStep = entries.isEmpty
        ? 1
        : max(1, (entries.length / maxLabels).ceil());

    // 5) Intervalle de grille Y, non nul
    double gridInterval = maxVal / 4;
    if (gridInterval == 0) gridInterval = 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi : ${goal.title}'),
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Camembert de progression générale ─────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Text(
                      'Progression générale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 16,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: pct,
                              color: mainColor,
                              title: '${pct.toStringAsFixed(1)} %',
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: 100 - pct,
                              color: Colors.grey.shade200,
                              title: '',
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Graphique en barres (évolution quotidienne) ───────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Évolution quotidienne',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (barGroups.isNotEmpty)
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            maxY: maxVal,
                            barGroups: barGroups,
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              horizontalInterval: gridInterval,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              ),
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (x, meta) {
                                    final idx = x.toInt();
                                    // on n'affiche qu'un label sur [labelStep]
                                    if (idx % labelStep != 0) return const SizedBox();
                                    final d = entries[idx].date;
                                    // si plusieurs points dans le même jour, on ajoute l'heure
                                    final sameDayCount = entries
                                        .where((e) =>
                                    e.date.year == d.year &&
                                        e.date.month == d.month &&
                                        e.date.day == d.day)
                                        .length;
                                    final fmt = sameDayCount > 1
                                        ? DateFormat('dd/MM HH:mm')
                                        : DateFormat('dd/MM');
                                    return Transform.rotate(
                                      angle: -pi / 4,
                                      child: Text(
                                        fmt.format(d),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: gridInterval,
                                  getTitlesWidget: (v, meta) => Text(
                                    '${v.toStringAsFixed(0)}$unit',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              topTitles: AxisTitles(),
                              rightTitles: AxisTitles(),
                            ),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                // simple tooltip sans paramètres obsolètes
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final val = entries[group.x.toInt()].value;
                                  return BarTooltipItem(
                                    '${val.toStringAsFixed(1)}$unit',
                                    const TextStyle(color: Colors.white),
                                  );
                                },
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 150,
                        child: Center(child: Text('Aucune donnée')),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Saisie d'une nouvelle mesure ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Valeur du jour ($unit)',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveTodayValue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
