import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  String balance = "0.00";
  String dueDate = "Not Set";
  String selectedMethod = "gcash";
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, dynamic>> recommendedMethods = [
    {'id': 'credit_card', 'label': 'Credit Card', 'icon': Icons.credit_card},
  ];

  final List<Map<String, dynamic>> otherMethods = [
    {'id': 'gcash', 'label': 'GCash', 'icon': Icons.phone_android},
    {'id': 'maya', 'label': 'Maya', 'icon': Icons.account_balance_wallet},
    {'id': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.business},
    {'id': 'cash', 'label': 'Cash', 'icon': Icons.payments},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getString('user_balance') ?? "1250.00";
      dueDate = prefs.getString('user_due_date') ?? "Oct 25, 2023";
      _amountController.text = balance.replaceAll(RegExp(r'[^0-9.]'), '');
    });
  }

  // UPDATED: Handle payment and navigate with arguments
  void _handlePayment() async {
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      _showSnackBar("Please enter a valid amount", isError: true);
      return;
    }

    // 1. Prepare transaction data for the receipt
    final Map<String, dynamic> transactionData = {
      'id':
          'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'amount': amount.toStringAsFixed(2),
      'status': 'Paid',
      'date': 'May 09, 2026',
      'dateTime': 'May 09, 2026 • 07:01 AM',
      'method': selectedMethod.toUpperCase(),
      'accountNumber': 'WTR-2026-8391',
      'meterNumber': 'MTR-8391-2026',
      'billingPeriod': 'April 2026',
      'consumption': '12.5', // Mock data
      'ratePerKwh': '10.50',
      'previousReading': '1040',
      'currentReading': '1052.5',
    };

    // 2. Clear balance in local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_balance', '0.00');

    // 3. Navigate to Receipt Screen
    if (!mounted) return;

    _showSnackBar("Payment of ₱${amount.toStringAsFixed(2)} successful!");

    Navigator.pushReplacementNamed(
      context,
      '/receipt',
      arguments: transactionData,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Make Payment",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            const Text(
              "Amount to Pay",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildAmountInput(),
            const SizedBox(height: 24),
            const Text(
              "Recommended",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildRecommendedGrid(),
            const SizedBox(height: 24),
            const Text(
              "Other Options",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...otherMethods.map((m) => _buildMethodTile(m)).toList(),
            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  // REWRITTEN: Reactive text based on controller
                  "Pay ₱${_amountController.text.isEmpty ? '0.00' : _amountController.text}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Balance Due", style: TextStyle(color: Colors.grey)),
              Text(
                "₱$balance",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Due Date", style: TextStyle(color: Colors.grey)),
              Text(
                dueDate,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Colors.amber,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Late payments may incur a ₱50 surcharge.",
                    style: TextStyle(fontSize: 11, color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      onChanged: (val) => setState(() {}),
      decoration: InputDecoration(
        prefixText: "₱ ",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildRecommendedGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: recommendedMethods.map((m) {
        bool isSelected = selectedMethod == m['id'];
        return GestureDetector(
          onTap: () => setState(() => selectedMethod = m['id']),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0EA5E9).withOpacity(0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0EA5E9)
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  m['icon'],
                  color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  m['label'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    bool isSelected = selectedMethod == method['id'];
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0EA5E9).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method['icon'],
              color: isSelected ? const Color(0xFF0EA5E9) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              method['label'],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF0EA5E9) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
