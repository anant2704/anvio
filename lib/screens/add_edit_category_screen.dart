// 📂 anvio/lib/screens/add_edit_category_screen.dart

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../widgets/color_picker.dart';
import '../widgets/icon_picker.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final DatabaseService _dbService = DatabaseService();

  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;
  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (_isEditing) {
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        name: _nameController.text,
        iconCodepoint: _selectedIcon.codePoint,
        colorValue: _selectedColor.value,
      );

      if (_isEditing) {
        // We need to find the original category to update it
        final originalCategory = _dbService.getCategories().firstWhere((c) => c.key == widget.category!.key);
        _dbService.updateCategory(originalCategory, newCategory);
      } else {
        _dbService.addCategory(newCategory);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 24),
              ColorPicker(
                initialColor: _selectedColor,
                onColorSelected: (color) => setState(() => _selectedColor = color),
              ),
              const SizedBox(height: 24),
              IconPicker(
                initialIcon: _selectedIcon,
                onIconSelected: (icon) => setState(() => _selectedIcon = icon),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  child: const Text('Save Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}