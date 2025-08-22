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
    await addDefaultCategories();
    await _createDefaultCashAccount();
  }

  Future<void> _createDefaultCashAccount() async {
    if (_accountBox.values.every((acc) => acc.bankName.toLowerCase() != 'cash')) {
      final cashAccount = Account(
        bankName: 'Cash',
        accountNumber: '----', // Using a non-numeric value to avoid conflicts
        balance: 0.0,
      );
      await addAccount(cashAccount);
    }
  }

  // --- Account Methods ---

  List<Account> getAccounts() {
    return _accountBox.values.toList();
  }

  Future<void> addAccount(Account account) async {
    await _accountBox.add(account);
  }

  Future<void> updateAccount(Account account) async {
    await account.save();
  }

  // --- Settings Methods ---
  
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

  // --- Category Methods ---

  List<Category> getCategories() {
    return _categoryBox.values.toList();
  }

  Future<void> addCategory(Category category) async {
    if (!_categoryBox.values.any((c) => c.name.toLowerCase() == category.name.toLowerCase())) {
      await _categoryBox.add(category);
    }
  }
  
  Future<void> updateCategory(Category oldCategory, Category newCategory) async {
    oldCategory.name = newCategory.name;
    oldCategory.iconCodepoint = newCategory.iconCodepoint;
    oldCategory.colorValue = newCategory.colorValue;
    await oldCategory.save();
  }

  Future<void> deleteCategory(Category category) async {
    await category.delete();
  }

  Future<void> addDefaultCategories() async {
    if (_categoryBox.isEmpty) {
      // ✨ FIX: Changed .toARGB32() to the correct .value property for all colors
      await addCategory(Category(name: 'Food', iconCodepoint: Icons.fastfood.codePoint, colorValue: Colors.orange.value));
      await addCategory(Category(name: 'Transport', iconCodepoint: Icons.directions_car.codePoint, colorValue: Colors.blue.value));
      await addCategory(Category(name: 'Shopping', iconCodepoint: Icons.shopping_bag.codePoint, colorValue: Colors.purple.value));
      await addCategory(Category(name: 'Bills', iconCodepoint: Icons.receipt_long.codePoint, colorValue: Colors.red.value));
      await addCategory(Category(name: 'Entertainment', iconCodepoint: Icons.movie.codePoint, colorValue: Colors.pink.value));
      await addCategory(Category(name: 'Groceries', iconCodepoint: Icons.local_grocery_store.codePoint, colorValue: Colors.green.value));
      await addCategory(Category(name: 'Health', iconCodepoint: Icons.medical_services.codePoint, colorValue: Colors.teal.value));
      await addCategory(Category(name: 'Salary', iconCodepoint: Icons.attach_money.codePoint, colorValue: Colors.lightGreen.value));
      await addCategory(Category(name: 'Uncategorized', iconCodepoint: Icons.category.codePoint, colorValue: Colors.grey.value));
    }
  }
  
  Category getCategoryByName(String name) {
      return _categoryBox.values.firstWhere((c) => c.name == name, orElse: () => getUncategorizedCategory());
  }
  
  Category getUncategorizedCategory() {
      return _categoryBox.values.firstWhere((c) => c.name == 'Uncategorized', orElse: () => Category(name: 'Uncategorized', iconCodepoint: Icons.category.codePoint, colorValue: Colors.grey.value));
  }

  // --- Transaction Methods ---

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

  Future<void> deleteTransaction(Transaction transaction) async {
    if (transaction.type == TransactionType.transfer) {
      final fromAccount = _accountBox.get(transaction.accountKey);
      final toAccount = _accountBox.get(transaction.toAccountKey);
      if (fromAccount != null) {
        fromAccount.balance += transaction.amount;
        fromAccount.save();
      }
      if (toAccount != null) {
        toAccount.balance -= transaction.amount;
        toAccount.save();
      }
    } else {
      final account = _accountBox.get(transaction.accountKey);
      if (account != null) {
        if (transaction.type == TransactionType.expense) {
          account.balance += transaction.amount;
        } else {
          account.balance -= transaction.amount;
        }
        account.save();
      }
    }
    await transaction.delete();
  }

  List<Transaction> detectSubscriptions() {
    final transactions = getTransactions().where((tx) => tx.type == TransactionType.expense).toList();
    Map<String, List<Transaction>> groupedByTitle = {};

    for (var tx in transactions) {
      if (groupedByTitle[tx.title] == null) {
        groupedByTitle[tx.title] = [];
      }
      groupedByTitle[tx.title]!.add(tx);
    }

    List<Transaction> subscriptions = [];
    groupedByTitle.forEach((title, txList) {
      if (txList.length > 1) {
        subscriptions.add(txList.first);
      }
    });

    return subscriptions;
  }
}