import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileState {
  final bool isLoading;
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? profile;

  ProfileState({
    this.isLoading = false,
    this.isSuccess = false,
    this.message = '',
    this.profile,
  });
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState());

  // Fetch profile from the server
  Future<void> fetchProfile() async {
    emit(ProfileState(isLoading: true));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      emit(ProfileState(message: 'Token not found'));
      print('Token not found');
      return;
    }

    print('Token retrieved: $token'); // Log token retrieval

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile Data: $data'); // Log the profile data
        emit(ProfileState(isSuccess: true, profile: data['data'], message: 'Profile retrieved successfully'));
      } else {
        emit(ProfileState(message: 'Failed to fetch profile'));
        print('API Request Failed');
      }
    } catch (e) {
      emit(ProfileState(message: 'Error: $e'));
      print('Error: $e');
    }
  }

  // Update profile on the server
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    emit(ProfileState(isLoading: true));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      emit(ProfileState(message: 'Token not found'));
      return;
    }

    try {
      // Log the data being sent
      print('Profile Data Sent: ${jsonEncode(profileData)}');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/users/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ProfileState(
          isSuccess: true,
          profile: data['user'],
          message: 'Profile updated successfully',
        ));
      } else {
        final error = jsonDecode(response.body);
        emit(ProfileState(
          message: 'Failed to update profile: ${error['message'] ?? 'Unknown error'}',
        ));
      }
    } catch (e) {
      emit(ProfileState(message: 'Error: $e'));
      print('Exception: $e');
    }
  }


}
