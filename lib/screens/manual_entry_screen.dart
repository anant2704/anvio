import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✨ NEW: Added missing import for DateFormat
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  Account? _fromAccount;
  Account? _toAccount;
  DateTime _selectedDate = DateTime.now();
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _dbService.getUncategorizedCategory();
    _accounts = _dbService.getAccounts();
    if (_accounts.length >= 2) {
      _fromAccount = _accounts[0];
      _toAccount = _accounts[1];
    } else if (_accounts.length == 1) {
      _fromAccount = _accounts[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == TransactionType.transfer && _fromAccount == _toAccount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("'From' and 'To' accounts cannot be the same.")),
        );
        return;
      }

      final newTransaction = Transaction(
        title: _selectedType == TransactionType.transfer ? 'Transfer' : _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory!,
        type: _selectedType,
        accountKey: _fromAccount?.key,
        toAccountKey: _toAccount?.key,
        notes: _notesController.text,
      );
      _dbService.addTransaction(newTransaction);
      Navigator.pop(context);
    }
  }

  void _showAccountPicker({required bool isFromAccount}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: _accounts.length,
          itemBuilder: (context, index) {
            final account = _accounts[index];
            return ListTile(
              leading: const Icon(Icons.account_balance),
              title: Text(account.bankName),
              subtitle: Text("...${account.accountNumber}"),
              onTap: () {
                setState(() {
                  if (isFromAccount) {
                    _fromAccount = account;
                  } else {
                    _toAccount = account;
                  }
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final categories = _dbService.getCategories();
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              leading: Icon(category.icon),
              title: Text(category.name),
              onTap: () {
                setState(() => _selectedCategory = category);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color getToggleBgColor(TransactionType type) {
      if (type == TransactionType.expense) return Colors.red.withOpacity(0.2);
      if (type == TransactionType.income) return Colors.green.withOpacity(0.2);
      return Colors.blueGrey.withOpacity(0.2);
    }

    Color getToggleFgColor(TransactionType type) {
      if (type == TransactionType.expense) return Colors.red;
      if (type == TransactionType.income) return Colors.green;
      return Colors.blueGrey;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      child: Center(
                        child: TextFormField(
                          controller: _amountController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: '0',
                            prefixText: '₹ ',
                            prefixStyle: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter an amount';
                            if (double.tryParse(value) == null) return 'Please enter a valid number';
                            return null;
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TransactionType>(
                        segments: const [
                          ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                          ButtonSegment(value: TransactionType.income, label: Text('Income')),
                          ButtonSegment(value: TransactionType.transfer, label: Text('Transfer')),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (newSelection) { setState(() { _selectedType = newSelection.first; }); },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                          selectedBackgroundColor: getToggleBgColor(_selectedType),
                          selectedForegroundColor: getToggleFgColor(_selectedType),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_selectedType == TransactionType.transfer) ...[
                      _buildPickerTile(
                        label: 'From',
                        value: '${_fromAccount?.bankName} (...${_fromAccount?.accountNumber})',
                        icon: Icons.arrow_circle_up_outlined,
                        onTap: () => _showAccountPicker(isFromAccount: true),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerTile(
                        label: 'To',
                        value: '${_toAccount?.bankName} (...${_toAccount?.accountNumber})',
                        icon: Icons.arrow_circle_down_outlined,
                        onTap: () => _showAccountPicker(isFromAccount: false),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title (e.g., Coffee, Salary)'),
                        validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildPickerTile(
                        label: 'Account',
                        value: '${_fromAccount?.bankName} (...${_fromAccount?.accountNumber})',
                        icon: Icons.account_balance_outlined,
                        onTap: () => _showAccountPicker(isFromAccount: true),
                      ),
                      const SizedBox(height: 16),
                      _buildPickerTile(
                        label: 'Category',
                        value: _selectedCategory?.name ?? 'Select a category',
                        icon: _selectedCategory?.icon ?? Icons.category_outlined,
                        onTap: _showCategoryPicker,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildPickerTile(
                      label: 'Date',
                      value: DateFormat('MMMM d, yyyy').format(_selectedDate),
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _selectDate(context),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveTransaction, child: const Text('Save Transaction'))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}