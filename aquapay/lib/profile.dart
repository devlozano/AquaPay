import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 1. Data state variables
  String fullName = "Loading...";
  String email = "Loading...";
  String accountNumber = "----";
  String meterNumber = "----";
  String contactNumber = "----";
  String address = "----";

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // 2. Fetch from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('user_name') ?? "Juan Dela Cruz";
      email = prefs.getString('user_email') ?? "juan@email.com";
      accountNumber = prefs.getString('user_account') ?? "0012-4456-78";
      meterNumber = prefs.getString('user_meter') ?? "MTR-2023-0982";
      contactNumber = prefs.getString('user_phone') ?? "+63 912 345 6789";
      address = prefs.getString('user_address') ?? "San Manuel, Tarlac";
    });
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all saved data
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // --- Avatar & Header Section ---
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : "U",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- Profile Info Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildProfileField(
                    Icons.numbers,
                    "Account Number",
                    accountNumber,
                  ),
                  _buildProfileField(Icons.speed, "Meter Number", meterNumber),
                  _buildProfileField(
                    Icons.phone_android,
                    "Contact Number",
                    contactNumber,
                  ),
                  _buildProfileField(
                    Icons.location_on_outlined,
                    "Address",
                    address,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Logout Button ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("Logout"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for the rows
  Widget _buildProfileField(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.blueGrey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
