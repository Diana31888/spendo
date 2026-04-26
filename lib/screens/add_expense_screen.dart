// Add Expense Screen - form to add a new expense to the database
// default currency is loaded from Settings (SharedPreferences)

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'TRY'; // will be updated from Settings

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant_outlined},
    {'name': 'Transport', 'icon': Icons.directions_bus_outlined},
    {'name': 'Housing', 'icon': Icons.home_outlined},
    {'name': 'Fun', 'icon': Icons.celebration_outlined},
    {'name': 'Health', 'icon': Icons.favorite_outline},
    {'name': 'Other', 'icon': Icons.receipt_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultCurrency();
  }

  // load currency from Settings so the form starts with the right currency
  Future<void> _loadDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? 'TRY';
    });
  }

  // return symbol for currency code
  String _symbol(String currency) {
    switch (currency) {
      case 'EUR': return '€';
      case 'RON': return 'lei';
      case 'USD': return '\$';
      case 'GBP': return '£';
      case 'CZK': return 'Kč';
      case 'HUF': return 'Ft';
      case 'PLN': return 'zł';
      default: return '₺';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A8A58)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Color(0xFF4A8A58),
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Color(0xFF4A8A58),
        ),
      );
      return;
    }

    // save expense with the selected currency
    final expense = Expense(
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      currency: _selectedCurrency,
    );

    await DBHelper.instance.insertExpense(expense);

    _titleController.clear();
    _amountController.clear();
    setState(() {
      _selectedCategory = 'Food';
      _selectedDate = DateTime.now();
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense saved!'),
          backgroundColor: Color(0xFF4A8A58),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'New expense',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D4A35),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // amount + currency picker on same row
              const Text('Amount', style: TextStyle(fontSize: 13, color: Color(0xFF777777))),
              const SizedBox(height: 6),
              Row(
                children: [
                  // currency dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F2EA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4A8A58), width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCurrency,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D4A35),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF4A8A58)),
                        items: ['TRY', 'EUR', 'RON', 'USD', 'GBP', 'CZK', 'HUF', 'PLN']
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('${_symbol(c)} $c'),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCurrency = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // amount text field
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D2D2B),
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        filled: true,
                        fillColor: const Color(0xFFF2F4F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4A8A58), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Description', style: TextStyle(fontSize: 13, color: Color(0xFF777777))),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2B)),
                decoration: InputDecoration(
                  hintText: 'e.g. Migros market',
                  filled: true,
                  fillColor: const Color(0xFFF2F4F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4A8A58), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Category', style: TextStyle(fontSize: 13, color: Color(0xFF777777))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE9F2EA) : const Color(0xFFF2F4F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4A8A58) : const Color(0xFFD8DDD6),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 15,
                            color: isSelected ? const Color(0xFF2D4A35) : const Color(0xFF999999),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            cat['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? const Color(0xFF2D4A35) : const Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Date', style: TextStyle(fontSize: 13, color: Color(0xFF777777))),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2B)),
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF4A8A58)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A8A58),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save expense',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}