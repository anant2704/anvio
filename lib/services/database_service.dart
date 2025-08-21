import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class DatabaseService {
  final Box<Transaction> _transactionBox = Hive.box<Transaction>('transactions');
  final Box<Category> _categoryBox = Hive.box<Category>('categories');
  final Box<Account> _accountBox = Hive.box<Account>('accounts');
  final Box _settingsBox = Hive.box('settings');

  Future<void> setupInitialData() async {
    await addDefaultCategories(); // ✨ FIX: Corrected method name
    await _createDefaultCashAccount();
  }

  Future<void> _createDefaultCashAccount() async {
    if (_accountBox.values.every((acc) => acc.bankName.toLowerCase() != 'cash')) {
      final cashAccount = Account(
        bankName: 'Cash',
        accountNumber: '----',
        balance: 0.0,
      );
      await addAccount(cashAccount);
    }
  }

  List<Account> getAccounts() {
    return _accountBox.values.toList();
  }

  Future<void> addAccount(Account account) async {
    await _accountBox.add(account);
  }

  Future<void> updateAccount(Account account) async {
    await account.save();
  }

  DateTime? getLastSmsScanTime() {
    final timestamp = _settingsBox.get('lastSmsScanTimestamp');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> setLastSmsScanTime(DateTime time) async {
    await _settingsBox.put('lastSmsScanTimestamp', time.millisecondsSinceEpoch);
  }

  List<Category> getCategories() {
    return _categoryBox.values.toList();
  }

  Future<void> addCategory(Category category) async {
    if (!_categoryBox.values.any((c) => c.name.toLowerCase() == category.name.toLowerCase())) {
      await _categoryBox.add(category);
    }
  }

  // ✨ FIX: Renamed from _addDefaultCategories to addDefaultCategories
  Future<void> addDefaultCategories() async {
    if (_categoryBox.isEmpty) {
      await addCategory(Category(name: 'Food', iconCodepoint: Icons.fastfood.codePoint, colorValue: Colors.orange.toARGB32()));
      await addCategory(Category(name: 'Transport', iconCodepoint: Icons.directions_car.codePoint, colorValue: Colors.blue.toARGB32()));
      await addCategory(Category(name: 'Shopping', iconCodepoint: Icons.shopping_bag.codePoint, colorValue: Colors.purple.toARGB32()));
      await addCategory(Category(name: 'Bills', iconCodepoint: Icons.receipt_long.codePoint, colorValue: Colors.red.toARGB32()));
      await addCategory(Category(name: 'Entertainment', iconCodepoint: Icons.movie.codePoint, colorValue: Colors.pink.toARGB32()));
      await addCategory(Category(name: 'Groceries', iconCodepoint: Icons.local_grocery_store.codePoint, colorValue: Colors.green.toARGB32()));
      await addCategory(Category(name: 'Health', iconCodepoint: Icons.medical_services.codePoint, colorValue: Colors.teal.toARGB32()));
      await addCategory(Category(name: 'Salary', iconCodepoint: Icons.attach_money.codePoint, colorValue: Colors.lightGreen.toARGB32()));
      await addCategory(Category(name: 'Uncategorized', iconCodepoint: Icons.category.codePoint, colorValue: Colors.grey.toARGB32()));
    }
  }
  
  Category getCategoryByName(String name) {
      return _categoryBox.values.firstWhere((c) => c.name == name, orElse: () => getUncategorizedCategory());
  }
  
  Category getUncategorizedCategory() {
      return _categoryBox.values.firstWhere((c) => c.name == 'Uncategorized', orElse: () => Category(name: 'Uncategorized', iconCodepoint: Icons.category.codePoint, colorValue: Colors.grey.toARGB32()));
  }

  List<Transaction> getTransactions() {
    final transactions = _transactionBox.values.toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> addTransaction(Transaction transaction) async {
    _updateBalanceForNewTransaction(transaction);
    await _transactionBox.add(transaction);
  }

  void _updateBalanceForNewTransaction(Transaction tx) {
    if (tx.type == TransactionType.transfer) {
      final fromAccount = _accountBox.get(tx.accountKey);
      final toAccount = _accountBox.get(tx.toAccountKey);
      if (fromAccount != null) {
        fromAccount.balance -= tx.amount;
        fromAccount.save();
      }
      if (toAccount != null) {
        toAccount.balance += tx.amount;
        toAccount.save();
      }
    } else {
      final account = _accountBox.get(tx.accountKey);
      if (account != null) {
        if (tx.type == TransactionType.expense) {
          account.balance -= tx.amount;
        } else {
          account.balance += tx.amount;
        }
        account.save();
      }
    }
  }

  void updateBalanceForEditedTransaction({
    required Transaction oldTransaction,
    required Transaction newTransaction,
  }) {
    if (oldTransaction.type == TransactionType.transfer) {
      final oldFromAccount = _accountBox.get(oldTransaction.accountKey);
      final oldToAccount = _accountBox.get(oldTransaction.toAccountKey);
      if (oldFromAccount != null) {
        oldFromAccount.balance += oldTransaction.amount;
        oldFromAccount.save();
      }
      if (oldToAccount != null) {
        oldToAccount.balance -= oldTransaction.amount;
        oldToAccount.save();
      }
    } else {
      final oldAccount = _accountBox.get(oldTransaction.accountKey);
      if (oldAccount != null) {
        if (oldTransaction.type == TransactionType.expense) {
          oldAccount.balance += oldTransaction.amount;
        } else {
          oldAccount.balance -= oldTransaction.amount;
        }
        oldAccount.save();
      }
    }
    _updateBalanceForNewTransaction(newTransaction);
  }
}