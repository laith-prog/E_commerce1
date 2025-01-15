import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/OtpCubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'VerifyOtpPage.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (_) => OtpCubit(),
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.isSuccess) {
                // OTP sent successfully, navigate to the Verify OTP screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtpScreen(
                      phoneNumber: phoneController.text,
                    ),
                  ),
                );
              } else if (state.message.isNotEmpty) {
                // Show the error message if the OTP request fails
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  state.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () {
                      if (phoneController.text.isNotEmpty) {
                        context.read<OtpCubit>().sendOtp(phoneController.text);
                      }
                    },
                    child: Text('Send OTP'),
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
