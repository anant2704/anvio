import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // ✨ UPDATED: Gradient changed to a sleek black/charcoal style.
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.bankName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                account.bankName.toLowerCase() == 'cash' ? 'In Hand' : "A/c No. ...${account.accountNumber}",
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
              const Spacer(),
              Text(
                NumberFormat.currency(locale: 'en_IN', symbol: '₹ ').format(account.balance),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}