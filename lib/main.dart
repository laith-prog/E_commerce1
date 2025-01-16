import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SplashScreen/SplashScreen.dart';
import 'layout/HomeScreen.dart';
import 'Auth/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences and check if token exists
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  // Now run the app and pass the token as parameter to MyApp
  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}
