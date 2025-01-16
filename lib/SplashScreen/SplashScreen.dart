import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/LoginScreen.dart';
import '../layout/HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 5)); // Show splash screen for 3 seconds

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF9F4), // Darker background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image without border, larger size, and blended with background
            Image.asset(
              'assets/logo_transparent.png', // Ensure this path is correct
              width: 250,  // Larger size for the logo
              height: 250,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Text(
              'Store2Door',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF47C7C),  // Matches primary color of the app
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 10),
            // Updated Slogan with a larger font and contrasting color
            Text(
              'From Your Local Store to Your Doorstep',
              style: TextStyle(
                fontSize: 22, // Increased font size for better emphasis
                fontStyle: FontStyle.italic,
                color: Color(0xFF2C2C2C), // Dark brown color for better contrast
                fontWeight: FontWeight.w500, // Slightly bolder for emphasis
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF47C7C)), // Spinner color
            ),
          ],
        ),
      ),
    );
  }
}
