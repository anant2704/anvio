
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'database_service.dart';

class SmsParserService {
  final DatabaseService _dbService = DatabaseService();

  Transaction? parseSms(String messageBody) {
    final body = messageBody.toLowerCase();
    double? amount;
    String? merchant;
    TransactionType type;

    if (body.contains('debited') || body.contains('spent')) {
      type = TransactionType.expense;
    } else if (body.contains('credited')) {
      type = TransactionType.income;
    } else {
      return null;
    }

    final amountRegex = RegExp(r'(?:rs\.?|inr)\s*([\d,]+\.?\d*)');
    final match = amountRegex.firstMatch(body);

    if (match != null && match.group(1) != null) {
      final amountString = match.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountString);
    }

    if (amount == null) {
      return null;
    }

    if (body.contains('zomato') || body.contains('swiggy')) {
      merchant = 'Food Delivery';
    } else if (body.contains('uber') || body.contains('ola')) {
      merchant = 'Cab Ride';
    } else {
      merchant = 'Unknown Transaction';
    }
    
    Category category = _dbService.getUncategorizedCategory();

    dynamic accountKey;
    final accRegex = RegExp(r'(?:a/c|acct|account).*(x|[*]{2,})(\d{4})');
    final accMatch = accRegex.firstMatch(body);
    if (accMatch != null && accMatch.group(2) != null) {
      final accNumber = accMatch.group(2)!;
      final accounts = _dbService.getAccounts();
      // Find the first account that matches the number AND is not the cash account
      final matchingAccount = accounts.firstWhere(
        (acc) => acc.accountNumber == accNumber && acc.bankName.toLowerCase() != 'cash',
        orElse: () => accounts.firstWhere((acc) => acc.bankName.toLowerCase() != 'cash', orElse: () => Account(bankName: 'Default', accountNumber: '0000', balance: 0))
      );
      if (matchingAccount.isInBox) {
        accountKey = matchingAccount.key;
      }
    }

    return Transaction(
      title: merchant,
      amount: amount,
      date: DateTime.now(),
      category: category,
      type: type,
      originalSms: messageBody,
      accountKey: accountKey,
    );
  }
}