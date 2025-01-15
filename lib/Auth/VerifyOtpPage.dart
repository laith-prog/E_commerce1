import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/HomeScreen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;

  VerifyOtpScreen({required this.phoneNumber});

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController otpController = TextEditingController();

  Future<void> verifyOtp(String otp) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/auth/verify-otp'),
      body: {
        'phone_number': widget.phoneNumber,
        'otp': otp,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      // Save the token to shared preferences
      await saveToken(token);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('OTP verified successfully!'),
      ));
      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),  // Navigate to HomeScreen
      );
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['message']),
      ));
    }
  }

  // Function to save the token in shared preferences
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);  // Save token
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (otpController.text.isNotEmpty) {
                  verifyOtp(otpController.text);
                }
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
