// 📂 anvio/lib/main.dart

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
      themeMode: ThemeMode.system,
      home: const StartupScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // GitHub Dark Theme Colors
    const ghDarkBg = Color(0xFF0d1117);
    const ghDarkCard = Color(0xFF161b22);
    const ghDarkAccent = Color(0xFF58a6ff);
    const ghDarkGreen = Color(0xFF3fb950);

    // Groww Light Theme Colors
    const gwLightBg = Color(0xFFFFFFFF);
    const gwLightCard = Color(0xFFF5F5F5);
    const gwLightAccent = Color(0xFF00B386);
    const gwLightText = Color(0xFF44475b);

    var baseTheme = ThemeData(
      brightness: brightness,
      fontFamily: 'Roboto',
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.dark ? ghDarkBg : gwLightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brightness == Brightness.dark ? ghDarkAccent : gwLightAccent,
        brightness: brightness,
        primary: brightness == Brightness.dark ? ghDarkAccent : gwLightAccent,
        secondary: brightness == Brightness.dark ? ghDarkGreen : Colors.teal,
        surface: brightness == Brightness.dark ? ghDarkCard : gwLightCard,
        onSurface: brightness == Brightness.dark ? Colors.white : gwLightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: brightness == Brightness.dark ? Colors.white70 : gwLightText),
        titleTextStyle: TextStyle(
          color: brightness == Brightness.dark ? Colors.white : gwLightText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: brightness == Brightness.dark ? ghDarkCard : gwLightBg,
        selectedItemColor: brightness == Brightness.dark ? ghDarkAccent : gwLightAccent,
        unselectedItemColor: Colors.grey,
        elevation: 5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.dark ? ghDarkCard : gwLightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brightness == Brightness.dark ? ghDarkAccent : gwLightAccent,
        foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
    );
  }
}