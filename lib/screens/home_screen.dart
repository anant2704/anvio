// 📂 anvio/lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/sms_parser_service.dart';
import '../widgets/account_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_list_item.dart';
import 'manual_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onInsightsTapped; // Accepts the function from MainScreen

  const HomeScreen({super.key, required this.onInsightsTapped});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  final SmsParserService _smsParser = SmsParserService();
  final SmsQuery _smsQuery = SmsQuery();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _dbService.setupInitialData();
    // Automatically sync SMS on startup
    await _requestAndProcessSms();
  }

  Future<void> _requestAndProcessSms() async {
    if (_isSyncing) return;
    setState(() { _isSyncing = true; });

    var status = await Permission.sms.request();
    if (status.isGranted) {
      final DateTime? lastScanTime = _dbService.getLastSmsScanTime();
      List<SmsMessage> allMessages = await _smsQuery.getAllSms;
      
      List<SmsMessage> newMessages = allMessages.where((msg) {
        if (msg.date == null) return false;
        return lastScanTime == null || msg.date!.isAfter(lastScanTime);
      }).toList();

      if (newMessages.isNotEmpty) {
        for (SmsMessage message in newMessages) {
          if (message.body != null) {
            Transaction? transaction = _smsParser.parseSms(message.body!);
            if (transaction != null) {
              transaction.date = message.date!;
              await _dbService.addTransaction(transaction);
            }
          }
        }
        newMessages.sort((a, b) => b.date!.compareTo(a.date!));
        await _dbService.setLastSmsScanTime(newMessages.first.date!);
      }
    } else {
      _showPermissionDeniedDialog();
    }
    if (mounted) { setState(() { _isSyncing = false; }); }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('Anvio needs SMS permission to automatically track expenses. Please grant the permission from your phone settings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          TextButton(onPressed: () { openAppSettings(); Navigator.pop(context); }, child: const Text('Open Settings')),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Map<String, List<Transaction>> _groupTransactionsByMonth(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      String monthYear = DateFormat('MMMM yyyy').format(tx.date);
      if (grouped[monthYear] == null) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              _getGreeting(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            actions: [
              if (_isSyncing)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0))),
                )
              else
                IconButton(
                  icon: Icon(Icons.sync, color: Theme.of(context).iconTheme.color),
                  onPressed: _requestAndProcessSms,
                  tooltip: 'Sync SMS',
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Account>('accounts').listenable(),
              builder: (context, Box<Account> box, _) {
                final accounts = _dbService.getAccounts();
                if (accounts.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 120,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.46),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      return AccountCard(account: accounts[index]);
                    },
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuickActionButton(icon: Icons.add, label: 'Add Expense', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManualEntryScreen()));
                  }),
                  QuickActionButton(icon: Icons.sync, label: 'Sync SMS', onTap: _requestAndProcessSms),
                  QuickActionButton(icon: Icons.insights, label: 'Insights', onTap: widget.onInsightsTapped),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Transaction History", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box<Transaction>('transactions').listenable(),
            builder: (context, Box<Transaction> box, _) {
              final transactions = _dbService.getTransactions();
              if (transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: _isSyncing 
                        ? const CircularProgressIndicator()
                        : const Text("No transactions yet. Tap 'Sync SMS' to begin.", style: TextStyle(color: Colors.grey))
                    ),
                  ),
                );
              }
              final grouped = _groupTransactionsByMonth(transactions);
              final months = grouped.keys.toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final monthKey = months[index];
                    final monthlyTransactions = grouped[monthKey]!;
                    
                    double totalIncome = monthlyTransactions.where((tx) => tx.type == TransactionType.income).fold(0.0, (sum, item) => sum + item.amount);
                    double totalExpense = monthlyTransactions.where((tx) => tx.type == TransactionType.expense).fold(0.0, (sum, item) => sum + item.amount);
                    double netFlow = totalIncome - totalExpense;
                    final bool isSaved = netFlow >= 0;
                    final String headerLabel = isSaved ? 'Net Savings' : 'Net Spending';
                    final Color headerColor = isSaved ? const Color(0xFF00B386) : Colors.red;
                    final double displayAmount = netFlow.abs();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(monthKey, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              Text(
                                '$headerLabel: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(displayAmount)}',
                                style: TextStyle(color: headerColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ...monthlyTransactions.map((tx) => TransactionListItem(transaction: tx)),
                      ],
                    );
                  },
                  childCount: months.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}