// 📂 anvio/lib/screens/insights_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Financial Insights"),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInsightCard(
            context,
            title: "AI Insight",
            content: "You've spent 20% more on Food this month compared to last month.",
            icon: Icons.auto_awesome,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text("Spending by Category", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(color: Colors.orange, value: 40, title: '40%', radius: 50),
                  PieChartSectionData(color: Colors.blue, value: 30, title: '30%', radius: 50),
                  PieChartSectionData(color: Colors.purple, value: 15, title: '15%', radius: 50),
                  PieChartSectionData(color: Colors.red, value: 15, title: '15%', radius: 50),
                ],
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Monthly Trends", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.purple)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.purple)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.purple)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.purple)]),
                ],
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text("Week ${value.toInt()+1}"))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Achievements", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAchievementCard(title: "Budget Master", subtitle: "Stayed within budget for 3 months in a row!", icon: Icons.military_tech, achieved: true),
          _buildAchievementCard(title: "Savings Streak", subtitle: "Saved money for 7 consecutive days.", icon: Icons.local_fire_department, achieved: false),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, {required String title, required String content, required IconData icon, required Color color}) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard({required String title, required String subtitle, required IconData icon, required bool achieved}) {
    return Card(
      color: achieved ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(icon, color: achieved ? Colors.green : Colors.grey),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: achieved ? Colors.green : Colors.grey)),
        subtitle: Text(subtitle, style: TextStyle(color: achieved ? Colors.green.shade900 : Colors.grey.shade700)),
      ),
    );
  }
}