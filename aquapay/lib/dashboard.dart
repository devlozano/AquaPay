import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 1. Remove 'final' and provide initial placeholders
  String fullName = "Loading...";
  String balance = "₱0.00";
  String accountNumber = "---- ---- --";
  String dueDate = "--/--/--";

  @override
  void initState() {
    super.initState();
    _loadData(); // 2. Trigger the data fetch as soon as the screen loads
  }

  // 3. The logic to grab data from storage
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Use the keys you used in your Auth/Login screen
      fullName = prefs.getString('user_name') ?? "Guest User";
      balance = prefs.getString('user_balance') ?? "₱0.00";
      accountNumber = prefs.getString('user_account') ?? "No Account";
      dueDate = prefs.getString('user_due_date') ?? "N/A";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: const [
            Icon(Icons.water_drop, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text(
              "AquaPay",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.teal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _FadeInUp(
              delay: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome back,",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    "$fullName 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Balance Card
            _FadeInUp(
              delay: 1,
              child: _BalanceCard(
                balance: balance,
                accountNumber: accountNumber,
                dueDate: dueDate,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _FadeInUp(
              delay: 2,
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "Pay Bill",
                      icon: Icons.credit_card,
                      color: Colors.blue,
                      textColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, '/pay'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: "Submit Reading",
                      icon: Icons.speed,
                      color: Colors.white,
                      textColor: Colors.blue,
                      isOutline: true,
                      onTap: () =>
                          Navigator.pushNamed(context, '/submit-reading'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscription Banner
            _FadeInUp(
              delay: 3,
              child: _SubscriptionBanner(
                onTap: () => Navigator.pushNamed(context, '/subscription'),
              ),
            ),
            const SizedBox(height: 32),

            // Recent Transactions Header
            _FadeInUp(
              delay: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "View All",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Transaction List
            _FadeInUp(
              delay: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _TransactionItem(
                      title: "Water Bill - Sept",
                      date: "Sep 12, 2023",
                      amount: "-₱1,100.00",
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _TransactionItem(
                      title: "Water Bill - Aug",
                      date: "Aug 10, 2023",
                      amount: "-₱1,250.00",
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _TransactionItem(
                      title: "Payment Refund",
                      date: "Aug 05, 2023",
                      amount: "+₱150.00",
                      isPositive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Components (Stateless as they represent static UI elements) ---

class _BalanceCard extends StatelessWidget {
  final String balance, accountNumber, dueDate;
  const _BalanceCard({
    required this.balance,
    required this.accountNumber,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Balance",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoTile(label: "Account Number", value: accountNumber),
              _InfoTile(label: "Due Date", value: dueDate),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, textColor;
  final bool isOutline;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.isOutline = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isOutline
              ? Border.all(color: Colors.blue.withOpacity(0.2), width: 2)
              : null,
          boxShadow: !isOutline
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _SubscriptionBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFEF3C7)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Subscription",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "Save now with AquaPay Premium",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title, date, amount;
  final bool isPositive;
  const _TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(
          isPositive ? Icons.add : Icons.receipt_long,
          color: Colors.blue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          color: isPositive ? Colors.green : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Animation Wrapper
class _FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;
  const _FadeInUp({required this.child, required this.delay});

  @override
  State<_FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<_FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
