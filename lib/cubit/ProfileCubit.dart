import 'dart:io';

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
    print('Token retrieved: $token'); // Log token retrieval
    print('Token retrieved: $token'); // Log token retrieval

    try {
      final response = await http.get(
        Uri.parse('http://192.168.45.88:8000/api/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile Data: $data'); // Log the profile data
        emit(ProfileState(
            isSuccess: true,
            profile: data['data'],
            message: 'Profile retrieved successfully'));
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
  Future<void> updateProfile(
      Map<String, dynamic> profileData, File? imageFile) async {
    emit(ProfileState(isLoading: true));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      emit(ProfileState(message: 'Token not found'));
      return;
    }

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.45.88:8000/api/users/update-profile'));
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['first_name'] = profileData['first_name'];
      request.fields['last_name'] = profileData['last_name'];
      request.fields['location'] = profileData['location'];

      // Add image if available
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile('profile_image', stream, length,
            filename: imageFile.path.split('/').last);
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);
      if (response.statusCode == 200) {
        final data = jsonDecode(responseString);
        emit(ProfileState(
          isSuccess: true,
          profile: data['user'],
          message: 'Profile updated successfully',
        ));
      } else {
        final error = jsonDecode(responseString);
        emit(ProfileState(
          message:
              'Failed to update profile: ${error['message'] ?? 'Unknown error'}',
        ));
      }
    } catch (e) {
      emit(ProfileState(message: 'Error: $e'));
      print('Exception: $e');
    }
  }

  Future<void> signOut(String token) async {
    try {
      final url = Uri.parse(
          'http://192.168.45.88:8000/api/auth/sign-out'); // Replace with your endpoint
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('Signed out successfully');
      } else {
        print('Failed to sign out: ${response.body}');
      }
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}
