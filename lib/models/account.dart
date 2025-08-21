
import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 3)
class Account extends HiveObject {
  @HiveField(0)
  late String bankName;

  @HiveField(1)
  late String accountNumber;

  @HiveField(2)
  late double balance;

  Account({
    required this.bankName,
    required this.accountNumber,
    required this.balance,
  });
}