import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ProfileCubit.dart';
import '../Auth/ProfileEditScreen.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA), // Off White for clean content sections
      appBar: AppBar(
        backgroundColor: Color(0xFFF47C7C), // Warm Pink for brand alignment
        elevation: 1,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state.message.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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

            String firstName = profile['first_name'] ?? 'Unknown';
            String lastName = profile['last_name'] ?? 'User';
            String phoneNumber =
                profile['phone_number'] ?? 'No phone number provided';
            String location = profile['location'] ?? 'Location not specified';
            String profileImage = profile['profile_image'] != null
                ? 'http://192.168.45.88:8000/storage/' + profile['profile_image']
                : 'https://via.placeholder.com/150';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Section
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF47C7C), // Warm Pink for header
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(
                              profileImage,
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  // Profile Details Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F4F4F), // Charcoal Gray
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Color(0xFFF47C7C), // Warm Pink
                                ),
                                SizedBox(width: 12),
                                Text(
                                  phoneNumber,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4F4F4F), // Charcoal Gray
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFFF47C7C), // Warm Pink
                                ),
                                SizedBox(width: 12),
                                Text(
                                  location,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF4F4F4F), // Charcoal Gray
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Edit Profile Button
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfilePage()),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF47C7C), // Warm Pink CTA
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // Additional Options (Optional Section)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(
                        thickness: 1,
                        color: Color(0xFFE0E0E0)), // Light Gray divider
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}