// Stats Screen - shows spending breakdown by category
// currency symbol is loaded from SharedPreferences

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  double _budget = 8000;
  String _currency = 'TRY';
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final budget = prefs.getDouble('monthly_budget') ?? 8000;
    final currency = prefs.getString('currency') ?? 'TRY';

    final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final expenses = await DBHelper.instance.getMonthlyExpenses(yearMonth);

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
      _budget = budget;
      _currency = currency;
    });
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

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return const Color(0xFF4A8A58);
      case 'transport': return const Color(0xFF7AB082);
      case 'housing': return const Color(0xFF2D4A35);
      case 'fun': return const Color(0xFFA5C9A9);
      case 'health': return const Color(0xFFC8DFC9);
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

  List<PieChartSectionData> _buildPieSections() {
    final sorted = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value;
      final percent = _grandTotal > 0 ? (cat.value / _grandTotal * 100) : 0.0;
      final isTouched = index == _touchedIndex;

      return PieChartSectionData(
        color: _categoryColor(cat.key),
        value: cat.value,
        title: isTouched ? '${percent.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 58,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final remaining = _budget - _grandTotal;
    final budgetProgress = (_grandTotal / _budget).clamp(0.0, 1.0);
    final sym = _symbol(_currency);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
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
              const SizedBox(height: 20),

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

                // budget summary card with dynamic currency
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F2EA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Spent', style: TextStyle(fontSize: 11, color: Color(0xFF5C7A62))),
                              Text(
                                '$sym${NumberFormat('#,##0').format(_grandTotal)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D4A35)),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Remaining', style: TextStyle(fontSize: 11, color: Color(0xFF5C7A62))),
                              Text(
                                '$sym${NumberFormat('#,##0').format(remaining)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: remaining < 0 ? Colors.redAccent : const Color(0xFF2D4A35),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budgetProgress,
                          backgroundColor: const Color(0xFFC5DFC8),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            budgetProgress > 0.85 ? Colors.redAccent : const Color(0xFF4A8A58),
                          ),
                          minHeight: 7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Budget: $sym${NumberFormat('#,##0').format(_budget)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF5C7A62)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'SPENDING BREAKDOWN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 1),
                ),
                const SizedBox(height: 16),

                // interactive donut chart - tap a section to see percentage
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                if (response == null || response.touchedSection == null) {
                                  _touchedIndex = -1;
                                } else {
                                  _touchedIndex = response.touchedSection!.touchedSectionIndex;
                                }
                              });
                            },
                          ),
                          sections: _buildPieSections(),
                          centerSpaceRadius: 65,
                          sectionsSpace: 3,
                        ),
                      ),
                      // center shows total spent
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 11, color: Color(0xFF888888))),
                          Text(
                            '$sym${NumberFormat('#,##0').format(_grandTotal)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D4A35),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // legend dots
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: sortedCategories.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _categoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(entry.key, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

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
                              child: Text(entry.key, style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2B))),
                            ),
                            Text(
                              '$sym${NumberFormat('#,##0.00').format(entry.value)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D4A35)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: const Color(0xFFEEEEEE),
                            valueColor: AlwaysStoppedAnimation<Color>(_categoryColor(entry.key)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(color: Color(0xFFEBEBEB)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total spent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2B))),
                    Text(
                      '$sym${NumberFormat('#,##0.00').format(_grandTotal)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D4A35)),
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