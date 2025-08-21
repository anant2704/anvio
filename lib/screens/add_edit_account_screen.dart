// 📂 anvio/lib/screens/add_edit_account_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import 'main_screen.dart';

class AddEditAccountScreen extends StatefulWidget {
  final Account? account;
  final bool isFirstSetup;

  const AddEditAccountScreen({
    super.key, 
    this.account,
    this.isFirstSetup = false,
  });

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _balanceController;
  final DatabaseService _dbService = DatabaseService();

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController(text: widget.account?.bankName ?? '');
    _accountNumberController = TextEditingController(text: widget.account?.accountNumber ?? '');
    _balanceController = TextEditingController(text: widget.account?.balance.toString() ?? '');
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        widget.account!.bankName = _bankNameController.text;
        widget.account!.accountNumber = _accountNumberController.text;
        widget.account!.balance = double.parse(_balanceController.text);
        _dbService.updateAccount(widget.account!);
      } else {
        final newAccount = Account(
          bankName: _bankNameController.text,
          accountNumber: _accountNumberController.text,
          balance: double.parse(_balanceController.text),
        );
        _dbService.addAccount(newAccount);
      }
      
      if (widget.isFirstSetup) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'Add Bank Account'),
        automaticallyImplyLeading: !widget.isFirstSetup,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (widget.isFirstSetup)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          "Welcome to Anvio! Let's add your first bank account to get started.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank Name (e.g., HDFC, SBI)'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a bank name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(labelText: 'Last 4 Digits of A/c No.'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, 
                        LengthLimitingTextInputFormatter(4)
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter the last 4 digits';
                        if (value.length != 4) return 'Must be exactly 4 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _balanceController,
                      decoration: const InputDecoration(labelText: 'Current Balance', prefixText: '₹ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a balance';
                        if (double.tryParse(value) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveAccount, child: const Text('Save Account'))),
            ),
          ],
        ),
      ),
    );
  }
}