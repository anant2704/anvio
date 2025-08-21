
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();
    final categories = dbService.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Category'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            leading: Icon(category.icon, color: Theme.of(context).colorScheme.primary),
            title: Text(category.name),
            onTap: () {
              Navigator.pop(context, category);
            },
          );
        },
      ),
    );
  }
}