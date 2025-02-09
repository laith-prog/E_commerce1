import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../cubit/ProfileCubit.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF47C7C),
        elevation: 1,
        title: Text(
          'Edit Profile',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Update Your Information",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F4F4F)),
                ),
                SizedBox(height: 20),
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: Color(0xFFF47C7C)),
                      SizedBox(width: 12),
                      Text(
                        _profileImage != null
                            ? 'Change Profile Picture'
                            : 'Add Profile Picture',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4F4F4F)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if (_profileImage != null)
                  Image.file(
                    _profileImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                else
                  Icon(Icons.person, size: 100, color: Colors.grey),
                SizedBox(height: 20),
                // First Name Input
                _buildTextField(
                  controller: firstNameController,
                  label: 'First Name',
                  icon: Icons.person,
                ),
                SizedBox(height: 20),
                // Last Name Input
                _buildTextField(
                  controller: lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 20),
                // Location Input
                _buildTextField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                ),
                SizedBox(height: 40),
                // Save Changes Button
                GestureDetector(
                  onTap: () {
                    context.read<ProfileCubit>().updateProfile({
                      'first_name': firstNameController.text,
                      'last_name': lastNameController.text,
                      'location': locationController.text,
                    }, _profileImage);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF47C7C),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable method to build styled text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF4F4F4F)),
        prefixIcon: Icon(icon, color: Color(0xFFF47C7C)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color(0xFFF47C7C)),
        ),
      ),
    );
  }
}
