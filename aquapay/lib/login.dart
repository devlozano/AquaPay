import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showPass = false;
  bool showConfirmPass = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // Updated to handle SharedPreferences and Navigation
  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text;

    // 1. Validation Logic
    if (!isLogin && name.isEmpty) {
      _showToast("Please enter your full name");
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showToast("Please enter a valid email");
      return;
    }
    if (pass.length < 6) {
      _showToast("Password must be at least 6 characters");
      return;
    }
    if (!isLogin && pass != _confirmPassController.text) {
      _showToast("Passwords do not match");
      return;
    }

    // 2. Persistent Storage Logic
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!isLogin) {
        // SIGN UP: Save the actual user details
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);

        // Initialize default wallet values for the dashboard
        await prefs.setString('user_balance', "₱0.00");
        await prefs.setString('user_account', "0012-4456-78");
        await prefs.setString('user_due_date', "Not Set");
      } else {
        // LOGIN: In a prototype, if name is empty, we set a default
        String? existingName = prefs.getString('user_name');
        if (existingName == null) {
          await prefs.setString('user_name', "Juan Dela Cruz");
        }
      }

      _showToast(isLogin ? "Welcome back!" : "Account created!");

      // 3. Navigation
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      _showToast("System Error: Could not save session.");
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0EA5E9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 40),
              _buildToggleSwitch(),
              const SizedBox(height: 32),
              _buildFormFields(),
              if (isLogin) _buildForgotPassword(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildLogo() {
    return Hero(
      tag: 'logo',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            "AquaPay",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            "Login",
            isLogin,
            () => setState(() => isLogin = true),
          ),
          _buildToggleButton(
            "Sign Up",
            !isLogin,
            () => setState(() => isLogin = false),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          if (!isLogin) ...[
            _buildTextField(
              controller: _nameController,
              hint: "Full Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
          ],
          _buildTextField(
            controller: _emailController,
            hint: "Email Address",
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passController,
            hint: "Password",
            icon: Icons.lock_outline,
            obscureText: !showPass,
            suffixIcon: IconButton(
              icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => showPass = !showPass),
            ),
          ),
          if (!isLogin) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPassController,
              hint: "Confirm Password",
              icon: Icons.lock_reset,
              obscureText: !showConfirmPass,
              suffixIcon: IconButton(
                icon: Icon(
                  showConfirmPass ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => showConfirmPass = !showConfirmPass),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Color(0xFF0EA5E9)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _handleSubmit,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isLogin ? "Login" : "Create Account",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.blueGrey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
