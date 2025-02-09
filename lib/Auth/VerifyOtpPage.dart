import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  Future<void> verifyOtp(String otp) async {
    final response = await http.post(
      Uri.parse('http://192.168.45.88:8000/api/auth/verify-otp'),
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

  // Move focus to the next field
  void _moveFocus(int index) {
    if (index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }
  }

  // Concatenate OTP from all text fields
  String getOtp() {
    return otpControllers.map((controller) => controller.text).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4),  // Light Beige background color
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),  // Custom AppBar height (adjust as needed)
        child: AppBar(
          backgroundColor: Colors.transparent,  // Transparent background for the app bar
          elevation: 0,
          title: Text(
            'Verify OTP',  // Display 'Verify OTP' in the AppBar
            style: TextStyle(
              color: Color(0xFF4F4F4F),  // Dark Gray for the AppBar title
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(  // Wrap in SingleChildScrollView to prevent pixel overflow
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo above the OTP input
            Image.asset(
              'assets/logo_transparent.png',
              height: 400, // Adjusted height for the logo
              width: 400,  // Adjusted width for the logo
            ),
            SizedBox(height: 40),

            // OTP Input Label
            Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 22,  // Increased font size for the label
                fontWeight: FontWeight.bold,
                color: Color(0xFF36454F),  // Dark Gray text color for label
              ),
            ),
            SizedBox(height: 10),

            // OTP Input Fields (6 separate fields)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  width: 50,
                  height: 50,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    decoration: InputDecoration(
                      // Customizing the border to make it thicker all the time
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFF47C7C),  // Warm Pink border color
                          width: 3,  // Thicker border width
                        ),
                        borderRadius: BorderRadius.circular(12),  // Rounded corners
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFF47C7C),  // Warm Pink when focused
                          width: 3,  // Thicker border width when focused
                        ),
                        borderRadius: BorderRadius.circular(12),  // Rounded corners
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: Color(0xFF4F4F4F)),  // Dark Gray text inside the input
                    inputFormatters: [
                      // Allow only 1 digit to be entered in each field
                      LengthLimitingTextInputFormatter(1),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      // Automatically move focus to the next field
                      if (value.isNotEmpty && index < 5) {
                        _moveFocus(index);
                      }

                      // Close the keyboard when all fields are filled
                      if (getOtp().length == 6) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 40),

            // Verify OTP Button (Adjusted color and size)
            ElevatedButton(
              onPressed: () {
                // Validate OTP input before sending the request
                if (getOtp().isEmpty) {
                  // Show "Please enter OTP" SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter OTP.')),
                  );
                } else if (getOtp().length < 6) {
                  // Show "OTP must be at least 6 digits" SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('OTP must be at least 6 digits.')),
                  );
                } else {
                  // If validation passes, verify OTP
                  verifyOtp(getOtp());
                }
              },
              child: Text('Verify OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF36454F),  // Medium Gray for the button background
                foregroundColor: Colors.white,  // White text color
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Larger padding for bigger button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 18),  // Bigger text for the button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
