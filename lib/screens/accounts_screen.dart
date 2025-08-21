// 📂 anvio/lib/screens/accounts_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import 'add_edit_account_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.asset('assets/anvio_logo.png'),
            ),
          ),
        ),
        title: const Text('Bank Accounts'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Account>('accounts').listenable(),
        builder: (context, Box<Account> box, _) {
          final accounts = _dbService.getAccounts();
          double totalBalance = accounts.fold(0.0, (sum, item) => sum + item.balance);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat.currency(locale: 'en_IN', symbol: '₹ ').format(totalBalance),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: accounts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == accounts.length) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            child: Icon(Icons.add, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          title: Text('Add a new account'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditAccountScreen()));
                          },
                        ),
                      );
                    }
                    
                    final account = accounts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
                        ),
                        title: Text(account.bankName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('A/c No. ${account.accountNumber}'),
                        trailing: Text(
                          NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(account.balance),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddEditAccountScreen(account: account)),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}