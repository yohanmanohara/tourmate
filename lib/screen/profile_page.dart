import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await image_picker.ImagePicker().pickImage(source: image_picker.ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.indigoAccent,
        elevation: 6,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : AssetImage('assets/images/profile.png') as ImageProvider,
                        child: _image == null
                            ? Icon(Icons.camera_alt, size: 30, color: Colors.white70)
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildTextField(controller: _nameController, label: 'Name', icon: Icons.person),
                  SizedBox(height: 16),
                  _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email),
                  SizedBox(height: 16),
                  _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone),
                  SizedBox(height: 16),
                  _buildTextField(controller: _addressController, label: 'Address', icon: Icons.location_on),
                  SizedBox(height: 16),
                  _buildTextField(controller: _dobController, label: 'Date of Birth', icon: Icons.calendar_today),
                  SizedBox(height: 16),
                  _buildDropdown(),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Profile Updated Successfully!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 5,
                    ),
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.person, color: Colors.deepPurpleAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: ['Male', 'Female', 'Other'].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _gender = value!;
        });
      },
    );
  }
}
