import 'package:shared_preferences/shared_preferences.dart';

// Function to save the token
Future<void> saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);  // Save the token in shared preferences
}
