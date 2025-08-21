// 📂 anvio/lib/models/transaction.dart

import 'package:hive/hive.dart';
import 'category.dart';
import 'account.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
  @HiveField(2)
  transfer,
}

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String title;
  @HiveField(1)
  late double amount;
  @HiveField(2)
  late DateTime date;
  @HiveField(3)
  late Category category;
  @HiveField(4)
  late TransactionType type;
  @HiveField(5)
  String? originalSms;
  @HiveField(6)
  dynamic accountKey;
  @HiveField(7)
  dynamic toAccountKey;
  
  @HiveField(8) // ✨ NEW
  String? notes;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.originalSms,
    this.accountKey,
    this.toAccountKey,
    this.notes, // ✨ NEW
  });

  Account? get account {
    if (accountKey != null) {
      return Hive.box<Account>('accounts').get(accountKey);
    }
    return null;
  }

  Account? get toAccount {
    if (toAccountKey != null) {
      return Hive.box<Account>('accounts').get(toAccountKey);
    }
    return null;
  }
}