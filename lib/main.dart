import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/account.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'screens/startup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(AccountAdapter());

  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Account>('accounts');
  await Hive.openBox('settings');
  
  runApp(const AnvioApp());
}

class AnvioApp extends StatelessWidget {
  const AnvioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anvio',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system, // Or set to ThemeMode.dark to force dark mode
      home: const StartupScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // Black & White Theme Colors
    final bgColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final cardColor = brightness == Brightness.dark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final accentColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    final subtleTextColor = brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    var baseTheme = ThemeData(
      brightness: brightness,
      fontFamily: 'Roboto',
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
        primary: accentColor,
        secondary: Colors.grey, // Neutral secondary color
        surface: cardColor,
        onSurface: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: subtleTextColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        elevation: 5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: bgColor,
      ),
    );
  }
}