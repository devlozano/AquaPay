import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receiving arguments from Navigator (similar to useLocation in React)
    final txn =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (txn == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No transaction data available.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/dashboard'),
                child: const Text("Go to Dashboard"),
              ),
            ],
          ),
        ),
      );
    }

    final bool isPaid = txn['status'] == "Paid";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Transaction Receipt",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Status Header
            const SizedBox(height: 10),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: isPaid ? Colors.green : Colors.amber,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPaid ? "Payment Successful" : "Payment Pending",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isPaid ? Colors.green.shade700 : Colors.amber.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "₱${txn['amount']}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Receipt Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Dotted Edge Simulation
                  _DottedEdge(),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _ReceiptRow(
                          label: "Transaction ID",
                          value: txn['id'] ?? "N/A",
                        ),
                        _ReceiptRow(
                          label: "Date & Time",
                          value: txn['dateTime'] ?? txn['date'] ?? "N/A",
                        ),
                        const Divider(height: 32),
                        _ReceiptRow(
                          label: "Account Number",
                          value: txn['accountNumber'] ?? "WTR-2024-8391",
                        ),
                        _ReceiptRow(
                          label: "Meter Number",
                          value: txn['meterNumber'] ?? "MTR-8391-2024",
                        ),

                        if (txn['billingPeriod'] != null) ...[
                          const Divider(height: 32),
                          _ReceiptRow(
                            label: "Billing Period",
                            value: txn['billingPeriod'],
                          ),
                          _ReceiptRow(
                            label: "Consumption",
                            value: "${txn['consumption']} m³",
                          ),
                        ],

                        const Divider(height: 32),
                        _ReceiptRow(
                          label: "Total Amount Due",
                          value: "₱${txn['amount']}",
                          isBold: true,
                        ),
                        _ReceiptRow(
                          label: "Amount Paid",
                          value: "₱${txn['amountPaid'] ?? txn['amount']}",
                          isBold: true,
                        ),
                        _ReceiptRow(
                          label: "Payment Method",
                          value: txn['method'] ?? "GCash",
                        ),

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.shade50
                                    : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                txn['status'],
                                style: TextStyle(
                                  color: isPaid
                                      ? Colors.green.shade700
                                      : Colors.amber.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Dotted Edge Simulation
                  _DottedEdge(isBottom: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Email Note
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mail_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Thank you for your payment. A copy of this receipt has been sent to your registered email address.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Action Buttons
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Receipt downloaded!")),
              ),
              icon: const Icon(Icons.download, size: 18),
              label: const Text("Download Receipt"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.blue.shade100),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (route) => false,
              ),
              icon: const Icon(Icons.home, size: 18, color: Colors.white),
              label: const Text(
                "Back to Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedEdge extends StatelessWidget {
  final bool isBottom;
  const _DottedEdge({this.isBottom = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: isBottom
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRect(
        child: CustomPaint(painter: _DottedPainter(isBottom: isBottom)),
      ),
    );
  }
}

class _DottedPainter extends CustomPainter {
  final bool isBottom;
  _DottedPainter({required this.isBottom});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var path = Path();
    double y = isBottom ? 0 : size.height;

    for (double x = 0; x < size.width; x += 10) {
      path.moveTo(x, y);
      path.lineTo(x + 5, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
