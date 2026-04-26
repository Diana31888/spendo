// Home Screen - shows monthly summary and recent expenses
// reads currency and budget from SharedPreferences set in Settings

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  double _monthlyTotal = 0;
  double _budget = 8000;
  String _userName = '';
  String _currency = 'TRY'; // loaded from settings

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final budget = prefs.getDouble('monthly_budget') ?? 8000;
    final name = prefs.getString('user_name') ?? '';
    final currency = prefs.getString('currency') ?? 'TRY';

    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final monthly = await DBHelper.instance.getMonthlyExpenses(yearMonth);
    final all = await DBHelper.instance.getAllExpenses();

    double total = 0;
    for (var e in monthly) {
      total += e.amount;
    }

    setState(() {
      _expenses = all.take(10).toList();
      _monthlyTotal = total;
      _budget = budget;
      _userName = name;
      _currency = currency;
    });
  }

  Future<void> _deleteExpense(int id) async {
    await DBHelper.instance.deleteExpense(id);
    _loadData();
  }

  // return currency symbol based on code
  String _symbol(String currency) {
    switch (currency) {
      case 'EUR': return '€';
      case 'RON': return 'lei ';
      case 'USD': return '\$';
      case 'GBP': return '£';
      case 'CZK': return 'Kč ';
      case 'HUF': return 'Ft ';
      case 'PLN': return 'zł ';
      default: return '₺';
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_outlined;
      case 'transport': return Icons.directions_bus_outlined;
      case 'housing': return Icons.home_outlined;
      case 'fun': return Icons.celebration_outlined;
      case 'health': return Icons.favorite_outline;
      default: return Icons.receipt_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return const Color(0xFFFEF6E4);
      case 'transport': return const Color(0xFFEDF7EE);
      case 'housing': return const Color(0xFFE8F0FE);
      case 'fun': return const Color(0xFFFCE4EC);
      case 'health': return const Color(0xFFE8F5E9);
      default: return const Color(0xFFF3E5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_monthlyTotal / _budget).clamp(0.0, 1.0);
    final remaining = _budget - _monthlyTotal;
    final sym = _symbol(_currency);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF4A8A58),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFFFAFAF8),
                floating: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userName.isNotEmpty)
                      Text(
                        'Hi, $_userName 👋',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    const Text(
                      'spendo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D4A35),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF4A8A58)),
                    onPressed: _loadData,
                  ),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // summary card with dynamic currency symbol
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F2EA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Spent this month',
                            style: TextStyle(fontSize: 12, color: Color(0xFF5C7A62)),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$sym${NumberFormat('#,##0.00').format(_monthlyTotal)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D4A35),
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFC5DFC8),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress > 0.85
                                    ? Colors.redAccent
                                    : const Color(0xFF4A8A58),
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget: $sym${NumberFormat('#,##0').format(_budget)}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF5C7A62)),
                              ),
                              Text(
                                'Left: $sym${NumberFormat('#,##0').format(remaining)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: remaining < 0
                                      ? Colors.redAccent
                                      : const Color(0xFF2D4A35),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'RECENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (_expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: const [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCCCCCC)),
                              SizedBox(height: 12),
                              Text(
                                'No expenses yet.\nTap Add to get started!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...(_expenses.map((expense) => Dismissible(
                        key: Key(expense.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                        onDismissed: (_) => _deleteExpense(expense.id!),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEBEBEB), width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _categoryColor(expense.category),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _categoryIcon(expense.category),
                                  size: 18,
                                  color: const Color(0xFF4A8A58),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2D2D2B),
                                      ),
                                    ),
                                    Text(
                                      expense.date,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                                    ),
                                  ],
                                ),
                              ),
                              // show amount with currency from expense record
                              Text(
                                '-${_symbol(expense.currency)}${NumberFormat('#,##0.00').format(expense.amount)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A8A58),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))).toList(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}