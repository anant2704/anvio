import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../screens/edit_transaction_screen.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final isTransfer = transaction.type == TransactionType.transfer;
    
    final amountColor = isExpense ? 
      (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : 
      (isTransfer ? Colors.blueGrey : Colors.green.shade600);
      
    final amountPrefix = isExpense ? '- ' : (isTransfer ? '' : '+ ');
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final itemContent = Container(
      color: Theme.of(context).cardTheme.color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (isTransfer)
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blueGrey.withOpacity(0.1),
              child: Icon(Icons.swap_horiz, color: Colors.blueGrey),
            )
          else
            CircleAvatar(
              radius: 24,
              backgroundColor: transaction.category.color.withOpacity(0.1),
              child: Icon(transaction.category.icon, color: transaction.category.color),
            ),
          
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  isTransfer 
                    ? "${transaction.account?.bankName ?? 'N/A'} → ${transaction.toAccount?.bankName ?? 'N/A'}"
                    : "${transaction.account?.bankName ?? 'Unlinked'} • ${DateFormat.yMMMd().format(transaction.date)}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text(
            amountPrefix + currencyFormat.format(transaction.amount),
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );

    return Dismissible(
      // ✨ FIX: Changed the key from ValueKey to ObjectKey.
      // This provides a more stable identity for each widget, preventing crashes during hot reload.
      key: ObjectKey(transaction), 
      direction: DismissDirection.horizontal,
      
      confirmDismiss: (direction) async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditTransactionScreen(transaction: transaction)),
        );
        return false;
      },
      
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      
      child: itemContent,
    );
  }
}