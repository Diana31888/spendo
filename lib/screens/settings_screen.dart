// Settings Screen - lets the user customize budget and base currency
// preferences are saved locally using SharedPreferences

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedCurrency = 'TRY';
  String _selectedCountry = 'Turkey';

  final List<String> _currencies = ['TRY', 'EUR', 'RON', 'USD', 'GBP'];
  final List<String> _countries = ['Turkey', 'Romania', 'Italy', 'Spain', 'France', 'Germany', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // load saved preferences when screen opens
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _budgetController.text = (prefs.getDouble('monthly_budget') ?? 8000).toString();
      _selectedCurrency = prefs.getString('currency') ?? 'TRY';
      _selectedCountry = prefs.getString('country') ?? 'Turkey';
    });
  }

  // save all settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setDouble(
      'monthly_budget',
      double.tryParse(_budgetController.text) ?? 8000,
    );
    await prefs.setString('currency', _selectedCurrency);
    await prefs.setString('country', _selectedCountry);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved!'),
          backgroundColor: Color(0xFF4A8A58),
        ),
      );
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D4A35),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // profile section
            _sectionLabel('PROFILE'),
            _card([
              _fieldRow('Your name', _nameController),
            ]),
            const SizedBox(height: 16),

            // budget section
            _sectionLabel('BUDGET'),
            _card([
              _fieldRow('Monthly budget', _budgetController, hint: '8000', isNumber: true),
            ]),
            const SizedBox(height: 16),

            // preferences section
            _sectionLabel('PREFERENCES'),
            _card([
              _dropdownRow('Currency', _currencies, _selectedCurrency, (val) {
                setState(() => _selectedCurrency = val!);
              }),
              const Divider(color: Color(0xFFEBEBEB), height: 1),
              _dropdownRow('Country', _countries, _selectedCountry, (val) {
                setState(() => _selectedCountry = val!);
              }),
            ]),
            const SizedBox(height: 32),

            // save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A8A58),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Save settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF999999), letterSpacing: 1),
      ),
    );
  }

  // white card container for grouped settings
  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _fieldRow(String label, TextEditingController controller, {String hint = '', bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2B))),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A8A58), fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownRow(String label, List<String> options, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2B))),
          const Spacer(),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            style: const TextStyle(fontSize: 14, color: Color(0xFF4A8A58), fontWeight: FontWeight.w500),
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A8A58), size: 18),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}