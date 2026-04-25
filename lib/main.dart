// Spendo - Erasmus Expense Tracker
// Built by Diana, Altinbas University, 2026
// Mobile Applications course - individual project

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/converter_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const SpendoApp());
}

class SpendoApp extends StatelessWidget {
  const SpendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // i went with sage green because it feels calm, not corporate
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A8A58),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAF8),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

// handles switching between the 5 screens when user taps the bottom nav
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
  const HomeScreen(),
  const AddExpenseScreen(),
  const StatsScreen(),
  const ConverterScreen(),
  const SettingsScreen(),
][_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFFFAFAF8),
        indicatorColor: const Color(0xFFE9F2EA),
        // rebuild the widget tree with the new screen index
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_outlined),
            selectedIcon: Icon(Icons.currency_exchange),
            label: 'Convert',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}