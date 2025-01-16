import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/OtpCubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'VerifyOtpPage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool showErrorMessages = false; // Flag to control error message visibility

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
            'Sign Up',  // Display Sign Up in the AppBar
            style: TextStyle(
              color: Color(0xFF4F4F4F),  // Dark Gray for the AppBar title
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(  // Wrap in SingleChildScrollView to prevent pixel overflow
        padding: const EdgeInsets.all(20.0),
        child: BlocProvider(
          create: (_) => OtpCubit(),
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.isSuccess) {
                // OTP sent successfully, show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('OTP sent successfully!')),
                );

                // Navigate to the Verify OTP screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtpScreen(
                      phoneNumber: phoneController.text,
                    ),
                  ),
                );
              } else if (state.message.isNotEmpty) {
                // Show the error message if OTP request fails
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo above the phone number input
                  Image.asset(
                    'assets/logo_transparent.png',
                    height: 400, // Your logo image
                    width: 400,  // Adjust the width for the logo size
                  ),
                  SizedBox(height: 40),

                  // Phone Number Input Label
                  Text(
                    'Enter Phone Number',
                    style: TextStyle(
                      fontSize: 22,  // Increased font size for the label
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF36454F),  // Dark Gray text color for label
                    ),
                  ),
                  SizedBox(height: 10),

                  // Phone Number Input Field
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Color(0xFF4F4F4F)),  // Dark Gray text for label
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF47C7C), width: 3),  // Warm Pink border color
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF47C7C)),  // Warm Pink border color
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Color(0xFF4F4F4F)),  // Dark Gray text inside the input
                  ),
                  SizedBox(height: 40),

                  // Send OTP Button (Adjusted color and size)
                  state.isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : ElevatedButton(
                    onPressed: () {
                      // Validate input
                      if (phoneController.text.isEmpty) {
                        // Show "Please enter a number" SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a number.')),
                        );
                      } else if (phoneController.text.length < 10) {
                        // Show "Number must be at least 10 digits" SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Number must be at least 10 digits.')),
                        );
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(phoneController.text)) {
                        // Show "Enter a valid number" SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enter a valid number.')),
                        );
                      } else {
                        // If validation passes, request OTP
                        context.read<OtpCubit>().sendOtp(phoneController.text);
                      }
                    },
                    child: Text('Send OTP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF36454F),  // Medium Gray for the button background
                      foregroundColor: Colors.white,  // White text color
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20), // Larger padding for bigger button
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: TextStyle(fontSize: 18),  // Bigger text for the button
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
