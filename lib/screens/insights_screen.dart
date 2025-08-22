import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import 'manage_categories_screen.dart';
import 'subscriptions_screen.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  Future<void> _exportToCsv(BuildContext context) async {
    final dbService = DatabaseService();
    final transactions = dbService.getTransactions();

    List<List<dynamic>> rows = [];
    rows.add(["Date", "Title", "Amount", "Type", "Category", "Account"]);

    for (var tx in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(tx.date),
        tx.title,
        tx.amount,
        tx.type.toString().split('.').last,
        tx.category.name,
        tx.account?.bankName ?? 'N/A'
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/anvio_transactions.csv";
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Here are my Anvio transactions.');
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Financial Insights"),
        centerTitle: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, box, _) {
          final transactions = dbService.getTransactions();
          final expenseTransactions = transactions.where((tx) => tx.type == TransactionType.expense).toList();

          Map<String, double> categorySpending = {};
          double totalExpenses = 0.0;
          for (var tx in expenseTransactions) {
            totalExpenses += tx.amount;
            categorySpending.update(tx.category.name, (value) => value + tx.amount, ifAbsent: () => tx.amount);
          }

          final pieChartSections = categorySpending.entries.map((entry) {
            final category = dbService.getCategoryByName(entry.key);
            return PieChartSectionData(
              color: category.color,
              value: entry.value,
              title: '${(entry.value / totalExpenses * 100).toStringAsFixed(0)}%',
              radius: 60,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text("Spending by Category", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: pieChartSections.isEmpty
                    ? const Center(child: Text("No expenses to show."))
                    : PieChart(PieChartData(sections: pieChartSections, centerSpaceRadius: 40)),
              ),
              const SizedBox(height: 16),
              // ✨ NEW: Legend for the pie chart
              _buildLegend(categorySpending, dbService),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.subscriptions_outlined),
                title: const Text('Subscription Tracker'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionsScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Manage Categories'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('Export to CSV'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportToCsv(context),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✨ NEW: Helper widget to build the pie chart legend
  Widget _buildLegend(Map<String, double> data, DatabaseService dbService) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: data.entries.map((entry) {
        final category = dbService.getCategoryByName(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: category.color,
            ),
            const SizedBox(width: 6),
            Text(category.name),
          ],
        );
      }).toList(),
    );
  }
}