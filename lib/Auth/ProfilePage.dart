import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ProfileCubit.dart';
import '../Auth/ProfileEditScreen.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // You can handle different states here, such as showing a snackbar
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state.profile == null) {
              return Center(child: Text('No profile data available.'));
            }

            var profile = state.profile!;

            // Use null-aware operators to prevent null errors
            String firstName = profile['first_name'] ?? 'Unknown';
            String lastName = profile['last_name'] ?? 'User';
            String phoneNumber = profile['phone_number'] ?? 'No phone number provided';
            String profileImage = profile['profile_image'] ?? 'https://via.placeholder.com/150';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  SizedBox(height: 20),
                  // Full Name
                  Text(
                    '$firstName $lastName',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  // Phone Number
                  Text('Phone: $phoneNumber'),
                  SizedBox(height: 20),
                  // Edit Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the profile edit page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                    },
                    child: Text('Edit Profile'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
