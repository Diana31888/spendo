// Stats Screen - shows spending breakdown by category for current month

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Expense> _expenses = [];
  Map<String, double> _categoryTotals = {};
  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final expenses = await DBHelper.instance.getMonthlyExpenses(yearMonth);

    // group expenses by category and sum amounts
    final Map<String, double> totals = {};
    double grand = 0;

    for (var e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      grand += e.amount;
    }

    setState(() {
      _expenses = expenses;
      _categoryTotals = totals;
      _grandTotal = grand;
    });
  }

  // color for each category bar
  Color _barColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return const Color(0xFF4A8A58);
      case 'transport': return const Color(0xFF7AB082);
      case 'housing': return const Color(0xFFA5C9A9);
      case 'fun': return const Color(0xFFC8DFC9);
      case 'health': return const Color(0xFF2D4A35);
      default: return const Color(0xFF9E9E9E);
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

  @override
  Widget build(BuildContext context) {
    // sort categories by amount descending
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: const Color(0xFF4A8A58),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D4A35),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 24),

              // empty state
              if (_expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Column(
                      children: const [
                        Icon(Icons.bar_chart_outlined, size: 48, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 12),
                        Text(
                          'No expenses this month yet.',
                          style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[

                // category breakdown bars
                const Text(
                  'BY CATEGORY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 1),
                ),
                const SizedBox(height: 14),

                ...sortedCategories.map((entry) {
                  final percent = _grandTotal > 0 ? entry.value / _grandTotal : 0.0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(_categoryIcon(entry.key), size: 16, color: const Color(0xFF4A8A58)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2B)),
                              ),
                            ),
                            Text(
                              '₺${NumberFormat('#,##0.00').format(entry.value)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D4A35),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // progress bar showing percentage of total
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: const Color(0xFFEEEEEE),
                            valueColor: AlwaysStoppedAnimation<Color>(_barColor(entry.key)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(color: Color(0xFFEBEBEB)),
                const SizedBox(height: 8),

                // total row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total spent',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2B)),
                    ),
                    Text(
                      '₺${NumberFormat('#,##0.00').format(_grandTotal)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D4A35),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}