import 'package:aquapay/login.dart';
import 'package:aquapay/make_payment.dart';
import 'package:aquapay/profile.dart';
import 'package:aquapay/subscription.dart';
import 'package:flutter/material.dart';
import 'package:aquapay/splash_screen.dart'; // Ensure this path matches your file structure
import 'package:aquapay/dashboard.dart'; // Ensure this path matches your file structure
import 'package:aquapay/submit.dart'; // Ensure this path matches your file structure
import 'package:aquapay/receipt.dart'; // Ensure this path matches your file structure

void main() => runApp(const AquaPayApp());

class AquaPayApp extends StatelessWidget {
  const AquaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // Set the Splash screen as the initial page
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // Your Splash code
        '/login': (context) => const AuthScreen(), // The code above
        '/dashboard': (context) =>
            const DashboardScreen(), // Your Dashboard code
        '/profile': (context) => const ProfileScreen(), // Your Profile code
        '/make_payment': (context) =>
            const MakePaymentScreen(), // Your Make Payment code
        '/submit': (context) =>
            const SubmitReadingScreen(), // Your Submit Payment code
        '/receipt': (context) => const ReceiptScreen(), // Your Receipt code
        '/subscription': (context) =>
            const SubscriptionScreen(), // Your Subscription code
      },
    );
  }
}
