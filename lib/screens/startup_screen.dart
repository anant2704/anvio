// 📂 anvio/lib/screens/startup_screen.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/account.dart';
import '../services/database_service.dart';
import 'add_edit_account_screen.dart';
import 'main_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    final dbService = DatabaseService();
    await dbService.setupInitialData(); // This creates the "Cash" account if needed
    
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final accountsBox = Hive.box<Account>('accounts');
    // Check if there is at least one account that is NOT a cash account.
    final hasBankAccounts = accountsBox.values.any((acc) => acc.bankName.toLowerCase() != 'cash');
    
    if (!hasBankAccounts) {
      // If no bank accounts exist, force the user to add one.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AddEditAccountScreen(isFirstSetup: true),
        ),
      );
    } else {
      // Bank accounts exist, proceed to the main app.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
                    ),
                  ),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/anvio_logo.png',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Anvio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}