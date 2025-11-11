import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../database/database.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Expense> expenses;
  const CategoryPieChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Group by category (assume you have a categories list; fetch via provider)
    final categoryTotals = <int, double>{};
    for (final e in expenses) {
      categoryTotals[e.categoryId] = (categoryTotals[e.categoryId] ?? 0) + e.amount;
    }
    
    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '\$${entry.value.toStringAsFixed(0)}',
        color: Colors.primaries[entry.key % Colors.primaries.length],
      );
    }).toList();
    
    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: 40),
    );
  }
}

class DailyBarChart extends StatelessWidget {
  final List<Expense> expenses;
  const DailyBarChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Group by day (last 7 days)
    final now = DateTime.now();
    final dailyTotals = <String, double>{};
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = day.toLocal().toString().split(' ')[0];
      dailyTotals[key] = expenses.where((e) => e.date.toLocal().toString().split(' ')[0] == key).fold(0.0, (sum, e) => sum + e.amount);
    }
    
    final barGroups = dailyTotals.entries.map((entry) {
      return BarChartGroupData(
        x: dailyTotals.keys.toList().indexOf(entry.key),
        barRods: [BarChartRodData(toY: entry.value, color: Colors.blue)],
      );
    }).toList();
    
    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(dailyTotals.keys.elementAt(value.toInt())),
            ),
          ),
        ),
      ),
    );
  }
}