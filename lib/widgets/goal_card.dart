import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitvista/models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;

  GoalCard(this.goal);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: goal.percentage, // Utilisation du getter percentage
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 10),
            Text('${(goal.percentage * 100).toStringAsFixed(1)}% atteint'),
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: LineChart(LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (i) => FlSpot(i.toDouble(), (goal.progress / goal.target) * (i + 1))),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  )
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
