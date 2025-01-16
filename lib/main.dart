import 'package:e_commerce1/cubit/ProfileCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layout/HomeScreen.dart';
import 'Auth/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the token exists in shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  runApp(
    BlocProvider(create: (context)=>ProfileCubit()..fetchProfile(),
    child: MyApp(token: token,),
    )
    );
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      routes: {
        '/login': (context) => LoginScreen(), // Replace with your actual register screen
        '/home': (context) => HomeScreen(),
      },
      home: token == null ? LoginScreen() : HomeScreen(),  // Navigate based on token
    );
  }
}
