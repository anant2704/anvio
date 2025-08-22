// 📂 anvio/lib/screens/subscriptions_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    // In a real app, this logic would be more advanced.
    // For now, we simulate finding subscriptions.
    final potentialSubscriptions = dbService.detectSubscriptions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
      ),
      body: potentialSubscriptions.isEmpty
          ? const Center(child: Text('No recurring payments detected.'))
          : ListView.builder(
              itemCount: potentialSubscriptions.length,
              itemBuilder: (context, index) {
                final sub = potentialSubscriptions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sub.category.color.withOpacity(0.1),
                    child: Icon(sub.category.icon, color: sub.category.color),
                  ),
                  title: Text(sub.title),
                  subtitle: Text("Last paid on ${DateFormat.yMMMd().format(sub.date)}"),
                  trailing: Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(sub.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
    );
  }
}