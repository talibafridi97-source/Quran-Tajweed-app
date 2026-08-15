import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _cashController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _savingsController = TextEditingController();
  final _businessController = TextEditingController();
  final _liabilitiesController = TextEditingController();

  double _totalAssets = 0.0;
  double _zakatPayable = 0.0;

  // Approximate Nisab Threshold in PKR (Silver Nisab ~52.5 Tolas / Gold Nisab ~7.5 Tolas)
  final double _silverNisabPKR = 150000.0; 

  void _calculateZakat() {
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    double gold = double.tryParse(_goldController.text) ?? 0.0;
    double silver = double.tryParse(_silverController.text) ?? 0.0;
    double savings = double.tryParse(_savingsController.text) ?? 0.0;
    double business = double.tryParse(_businessController.text) ?? 0.0;
    double liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;

    double netWealth = (cash + gold + silver + savings + business) - liabilities;

    setState(() {
      _totalAssets = netWealth > 0 ? netWealth : 0.0;
      if (_totalAssets >= _silverNisabPKR) {
        _zakatPayable = _totalAssets * 0.025; // 2.5% Zakat rate
      } else {
        _zakatPayable = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Zakat Calculator (حساب الزكاة)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Calculation Output Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryGreen, Color(0xFF007A72)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('Total Net Zakatable Wealth', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'PKR ${_totalAssets.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                const Text('Total Zakat Payable (2.5%)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'PKR ${_zakatPayable.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppConstants.gold, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _totalAssets >= _silverNisabPKR
                      ? 'Status: Nisab Threshold Met (Silver Nisab: ~PKR 150,000)'
                      : 'Status: Wealth below Nisab Threshold',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Enter Asset Values (PKR):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          _buildInputField('Cash in Hand & Bank Accounts', _cashController, Icons.account_balance_wallet),
          _buildInputField('Value of Gold & Gold Jewelry', _goldController, Icons.monetization_on),
          _buildInputField('Value of Silver', _silverController, Icons.workspace_premium),
          _buildInputField('Savings & Investments', _savingsController, Icons.savings),
          _buildInputField('Business Stock & Merchandise', _businessController, Icons.storefront),
          _buildInputField('Deduct Immediate Liabilities/Debts (-)', _liabilitiesController, Icons.money_off),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _calculateZakat,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Zakat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('Islamic Disclaimer:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'This Zakat calculator provides an estimate based on standard 2.5% rates. Please consult a qualified Islamic scholar for specific personal wealth or debt scenarios.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => _calculateZakat(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppConstants.primaryGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
