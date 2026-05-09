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

  // Data structure for payment instructions
  final Map<String, Map<String, String>> paymentDetails = {
    'gcash': {
      'accountName': 'Juan Dela Cruz',
      'accountNumber': '0912 345 6789',
      'instruction':
          'Send payment via Express Send. Please save a screenshot of the receipt.',
    },
    'maya': {
      'accountName': 'Juan Dela Cruz',
      'accountNumber': '0912 345 6789',
      'instruction':
          'Transfer via PayMaya. Keep your transaction reference number.',
    },
    'bank_transfer': {
      'accountName': 'Water Management Inc.',
      'accountNumber': '1234-5678-90',
      'bank': 'BDO Unibank',
      'instruction': 'Use your Account ID as the bank transfer description.',
    },
    'credit_card': {
      'accountName': 'Online Payment Portal',
      'accountNumber': '**** **** **** 4242',
      'instruction': 'Secure payment processed via Stripe.',
    },
    'cash': {
      'accountName': 'Barangay Office / Payment Center',
      'accountNumber': 'N/A',
      'instruction': 'Visit the nearest authorized payment center or office.',
    },
  };

  final List<Map<String, dynamic>> recommendedMethods = [
    {'id': 'credit_card', 'label': 'Credit Card', 'icon': Icons.credit_card},
    {'id': 'gcash', 'label': 'GCash', 'icon': Icons.phone_android},
    {'id': 'maya', 'label': 'Maya', 'icon': Icons.account_balance_wallet},
  ];

  final List<Map<String, dynamic>> otherMethods = [
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

  void _handlePayment() async {
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      _showSnackBar("Please enter a valid amount", isError: true);
      return;
    }

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
      'consumption': '12.5',
      'ratePerUnit': '5.00',
      'previousReading': '500',
      'currentReading': (500 + 12.5).toString(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_balance', '0.00');

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
              "Select Payment Method",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildRecommendedGrid(),
            const SizedBox(height: 12),
            ...otherMethods.map((m) => _buildMethodTile(m)).toList(),
            const SizedBox(height: 24),
            _buildDetailedInstructionCard(), // The new details section
            const SizedBox(height: 32),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInstructionCard() {
    final details = paymentDetails[selectedMethod]!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: Color(0xFF0EA5E9),
              ),
              const SizedBox(width: 8),
              Text(
                "Payment Details: ${selectedMethod.toUpperCase()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (details.containsKey('bank')) ...[
            _detailRow("Bank Name", details['bank']!),
            const SizedBox(height: 8),
          ],
          _detailRow("Account Name", details['accountName']!),
          const SizedBox(height: 8),
          _detailRow("Account Number", details['accountNumber']!),
          const SizedBox(height: 12),
          Text(
            details['instruction']!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
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

  Widget _buildPayButton() {
    return SizedBox(
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
          "Pay ₱${_amountController.text.isEmpty ? '0.00' : _amountController.text}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
