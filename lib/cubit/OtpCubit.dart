import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpState {
  final String message;
  final bool isLoading;
  final bool isSuccess;

  OtpState({this.message = '', this.isLoading = false, this.isSuccess = false});
}

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpState());

  // Function to send OTP
  Future<void> sendOtp(String phoneNumber) async {
    emit(OtpState(isLoading: true));

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/auth/send-otp'),
      body: {'phone_number': phoneNumber},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      emit(OtpState(message: data['message'], isSuccess: true, isLoading: false));
    } else {
      emit(OtpState(message: 'Failed to send OTP', isSuccess: false, isLoading: false));
    }
  }

  // Function to verify OTP
  Future<void> verifyOtp(String phoneNumber, String otp) async {
    emit(OtpState(isLoading: true));

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/auth/verify-otp'),
      body: {'phone_number': phoneNumber, 'otp': otp},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      emit(OtpState(message: 'OTP verified successfully', isSuccess: true, isLoading: false));
    } else {
      emit(OtpState(message: 'Invalid OTP', isSuccess: false, isLoading: false));
    }
  }
}
