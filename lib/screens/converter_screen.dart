// Converter Screen - live exchange rates with selectable source currency
// user picks which currency they're currently using (TRY, EUR, RON, etc.)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _amountController = TextEditingController(text: '1000');
  Map<String, double> _rates = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _sourceCurrency = 'TRY'; // user can change this

  // all supported currencies with flag, symbol, name
  final List<Map<String, String>> _allCurrencies = [
    {'code': 'TRY', 'symbol': '₺', 'name': 'Turkish Lira', 'flag': '🇹🇷'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro', 'flag': '🇪🇺'},
    {'code': 'RON', 'symbol': 'lei', 'name': 'Romanian Leu', 'flag': '🇷🇴'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar', 'flag': '🇺🇸'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound', 'flag': '🇬🇧'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
    {'code': 'CZK', 'symbol': 'Kč', 'name': 'Czech Koruna', 'flag': '🇨🇿'},
    {'code': 'HUF', 'symbol': 'Ft', 'name': 'Hungarian Forint', 'flag': '🇭🇺'},
    {'code': 'PLN', 'symbol': 'zł', 'name': 'Polish Zloty', 'flag': '🇵🇱'},
    {'code': 'SEK', 'symbol': 'kr', 'name': 'Swedish Krona', 'flag': '🇸🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  // fetch rates based on selected source currency
  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/$_sourceCurrency'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())),
        );
        setState(() {
          _rates = rates;
          _isLoading = false;
        });
      } else {
        setState(() { _isLoading = false; _hasError = true; });
      }
    } catch (e) {
      setState(() { _isLoading = false; _hasError = true; });
    }
  }

  double _convert(String targetCode) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final rate = _rates[targetCode] ?? 0;
    return amount * rate;
  }

  // show bottom sheet to pick source currency
  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Select your currency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D4A35)),
              ),
            ),
            ..._allCurrencies.map((currency) {
              final isSelected = currency['code'] == _sourceCurrency;
              return ListTile(
                leading: Text(currency['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(currency['name']!, style: const TextStyle(fontSize: 14)),
                subtitle: Text(currency['code']!, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4A8A58))
                    : null,
                onTap: () {
                  setState(() => _sourceCurrency = currency['code']!);
                  Navigator.pop(context);
                  _fetchRates(); // reload rates for new base currency
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // get the current source currency details
  Map<String, String> get _sourceCurrencyData =>
      _allCurrencies.firstWhere((c) => c['code'] == _sourceCurrency);

  @override
  Widget build(BuildContext context) {
    // show all currencies except the source one
    final targetCurrencies = _allCurrencies.where((c) => c['code'] != _sourceCurrency).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            const Text(
              'Currency converter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF2D4A35), letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _hasError ? Icons.wifi_off_outlined : Icons.bolt_outlined,
                  size: 14,
                  color: _hasError ? Colors.redAccent : const Color(0xFF4A8A58),
                ),
                const SizedBox(width: 4),
                Text(
                  _hasError ? 'No internet connection' : 'Live rates',
                  style: TextStyle(fontSize: 12, color: _hasError ? Colors.redAccent : const Color(0xFF888888)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _fetchRates,
                  child: const Text('Refresh', style: TextStyle(fontSize: 12, color: Color(0xFF4A8A58), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // source currency selector button
            const Text('I am spending in', style: TextStyle(fontSize: 13, color: Color(0xFF777777))),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _showCurrencyPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F2EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4A8A58), width: 1),
                ),
                child: Row(
                  children: [
                    Text(_sourceCurrencyData['flag']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sourceCurrencyData['name']!,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2D4A35)),
                        ),
                        Text(_sourceCurrency, style: const TextStyle(fontSize: 11, color: Color(0xFF5C7A62))),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A8A58)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // amount input
            const Text('Amount', style: TextStyle(fontSize: 13, color: Color(0xFF777777))),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF2D4A35)),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                suffixText: '${_sourceCurrencyData['symbol']} $_sourceCurrency',
                suffixStyle: const TextStyle(fontSize: 14, color: Color(0xFF4A8A58), fontWeight: FontWeight.w500),
                filled: true,
                fillColor: const Color(0xFFF2F4F0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4A8A58), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF4A8A58)))
            else if (_hasError)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Could not load rates. Check your internet and tap Refresh.',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              const Text('CONVERTED TO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 1)),
              const SizedBox(height: 12),
              ...targetCurrencies.map((currency) {
                final converted = _convert(currency['code']!);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEBEBEB), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Text(currency['flag']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currency['name']!, style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2B))),
                            Text(currency['code']!, style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                          ],
                        ),
                      ),
                      Text(
                        '${currency['symbol']} ${converted.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF2D4A35)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}