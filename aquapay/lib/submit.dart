import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitReadingScreen extends StatefulWidget {
  const SubmitReadingScreen({super.key});

  @override
  State<SubmitReadingScreen> createState() => _SubmitReadingScreenState();
}

class _SubmitReadingScreenState extends State<SubmitReadingScreen> {
  final TextEditingController _readingController = TextEditingController();

  double previousReading = 1040.0;
  double ratePerUnit = 12.00; // Example rate
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousData();
  }

  Future<void> _loadPreviousData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      previousReading =
          double.tryParse(prefs.getString('last_reading') ?? "1040.0") ??
          1040.0;
    });
  }

  void _handleSubmit() async {
    final String input = _readingController.text;
    final double? currentReading = double.tryParse(input);

    if (currentReading == null || currentReading < previousReading) {
      _showSnackBar(
        currentReading == null
            ? "Enter a valid reading"
            : "Reading lower than previous",
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Calculate consumption
    double consumption = currentReading - previousReading;
    double totalAmount = consumption * ratePerUnit;

    // Save to local storage so Dashboard/Payment screens update
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_balance', totalAmount.toStringAsFixed(2));
    await prefs.setString('last_reading', currentReading.toStringAsFixed(1));

    await Future.delayed(const Duration(seconds: 1)); // Simulation

    if (!mounted) return;
    _showSnackBar("Reading submitted: ₱${totalAmount.toStringAsFixed(2)}");
    Navigator.pop(context);
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
          "Submit Reading",
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),

            const Text(
              "Current Reading",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildReadingInput(),

            const SizedBox(height: 32),
            const Text(
              "Upload Proof (Meter Photo)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // --- PHOTO UPLOAD BUTTONS ---
            Row(
              children: [
                Expanded(child: _buildUploadButton(Icons.camera_alt, "Camera")),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUploadButton(Icons.photo_library, "Gallery"),
                ),
              ],
            ),

            const SizedBox(height: 48),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed, color: Color(0xFF0EA5E9)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Previous Reading",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                "$previousReading units",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingInput() {
    return TextField(
      controller: _readingController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: "Enter current meter digits",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  // UI Helper for the Camera/Gallery buttons
  Widget _buildUploadButton(IconData icon, String label) {
    return InkWell(
      onTap: () => _showSnackBar("Photo upload coming soon!", isError: false),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Submit Reading",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
