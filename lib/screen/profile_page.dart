import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final uuid = Uuid();

  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _gender = 'Male';
  String? _currentPhotoUrl;
  File? _image;
  DateTime? _selectedDate;
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userId = currentUser.uid;

        // Get the user document from Firestore
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Create UserModel from the data
          final UserModel user = UserModel.fromMap({
            'uid': _userId,
            ...userData,
          });

          setState(() {
            // Basic user data from UserModel
            _nameController.text = user.name ?? '';
            _emailController.text = user.email;
            _currentPhotoUrl = user.photoUrl;
            _userRole = user.role;

            // Extended profile data
            if (userData.containsKey('phoneNumber')) {
              _phoneController.text = userData['phoneNumber'] ?? '';
            }

            if (userData.containsKey('address')) {
              _addressController.text = userData['address'] ?? '';
            }

            if (userData.containsKey('gender')) {
              _gender = userData['gender'] ?? 'Male';
            }

            // Handle date of birth
            if (userData.containsKey('dob') && userData['dob'] != null) {
              _dobController.text = userData['dob'];
              try {
                _selectedDate = DateFormat('yyyy-MM-dd').parse(userData['dob']);
              } catch (e) {
                print('Error parsing date: $e');
              }
            }
          });
        } else {
          // If user document doesn't exist, try to create a basic one
          final userAuth = currentUser;
          final Map<String, dynamic> basicUserData = {
            'uid': _userId,
            'email': userAuth.email ?? '',
            'name': userAuth.displayName ?? '',
            'photoUrl': userAuth.photoURL,
            'role': 'user', // Default role
          };

          // Set controller values from auth data
          setState(() {
            _nameController.text = userAuth.displayName ?? '';
            _emailController.text = userAuth.email ?? '';
            _currentPhotoUrl = userAuth.photoURL;
            _userRole = 'user';
          });

          // Create the user document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userId)
              .set(basicUserData);

          _showSuccessToast('Profile created. Please complete your details.');
        }
      } else {
        // No user is logged in, redirect to login
        _showErrorToast('Please log in to view your profile');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _showErrorToast('Error loading profile: $e');
      print('Error loading profile data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await image_picker.ImagePicker().pickImage(
      source: image_picker.ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToS3() async {
    if (_image == null) return _currentPhotoUrl;

    try {
      // Get AWS credentials from .env
      final awsAccessKey = dotenv.env['AWS_ACCESS_KEY'];
      final awsSecretKey = dotenv.env['AWS_SECRET_KEY'];
      final awsRegion = dotenv.env['AWS_REGION'];
      final bucketName = dotenv.env['AWS_BUCKET_NAME'];

      if (awsAccessKey == null ||
          awsSecretKey == null ||
          awsRegion == null ||
          bucketName == null) {
        throw Exception('AWS credentials not found in environment variables');
      }

      // Generate unique filename with UUID to prevent conflicts
      final fileExtension = path.extension(_image!.path);
      final uniqueId = uuid.v4();
      final fileName =
          'profiles/${_userId}_${DateTime.now().millisecondsSinceEpoch}_$uniqueId$fileExtension';

      // Read file as bytes
      final bytes = await _image!.readAsBytes();

      // Prepare the URL for the S3 bucket
      final endpoint =
          'https://$bucketName.s3.$awsRegion.amazonaws.com/$fileName';

      // Get current date and time in UTC
      final now = DateTime.now().toUtc();

      final dateStamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final amzDate = '$dateStamp' +
          'T${now.hour.toString().padLeft(2, '0')}' +
          '${now.minute.toString().padLeft(2, '0')}' +
          '${now.second.toString().padLeft(2, '0')}Z';

      final contentType = 'image/${fileExtension.substring(1)}';
      final payloadHash = sha256.convert(bytes).toString();

      final headers = {
        'host': '$bucketName.s3.$awsRegion.amazonaws.com',
        'content-type': contentType,
        'x-amz-content-sha256': payloadHash,
        'x-amz-date': amzDate,
        'x-amz-acl': 'public-read',
      };

      final signedHeadersKeys = headers.keys.toList()..sort();
      final signedHeadersStr = signedHeadersKeys.join(';');

      final canonicalHeaders =
          signedHeadersKeys.map((key) => '$key:${headers[key]}\n').join();

      final canonicalUri = '/$fileName';
      final canonicalQueryString = '';

      final canonicalRequest = [
        'PUT',
        canonicalUri,
        canonicalQueryString,
        canonicalHeaders,
        signedHeadersStr,
        payloadHash,
      ].join('\n');

      final algorithm = 'AWS4-HMAC-SHA256';
      final credentialScope = '$dateStamp/$awsRegion/s3/aws4_request';

      final canonicalRequestHash =
          sha256.convert(utf8.encode(canonicalRequest)).toString();

      final stringToSign = [
        algorithm,
        amzDate,
        credentialScope,
        canonicalRequestHash,
      ].join('\n');

      final kSecret = utf8.encode('AWS4$awsSecretKey');
      final kDate = Hmac(sha256, kSecret).convert(utf8.encode(dateStamp)).bytes;
      final kRegion = Hmac(sha256, kDate).convert(utf8.encode(awsRegion)).bytes;
      final kService = Hmac(sha256, kRegion).convert(utf8.encode('s3')).bytes;
      final kSigning =
          Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;

      final signature =
          Hmac(sha256, kSigning).convert(utf8.encode(stringToSign)).toString();

      final authorization =
          '$algorithm Credential=$awsAccessKey/$credentialScope, ' +
              'SignedHeaders=$signedHeadersStr, Signature=$signature';

      final requestHeaders = {
        'Host': '$bucketName.s3.$awsRegion.amazonaws.com',
        'Content-Type': contentType,
        'x-amz-content-sha256': payloadHash,
        'x-amz-date': amzDate,
        'x-amz-acl': 'public-read',
        'Authorization': authorization,
      };

      // Send request to S3
      final response = await http.put(
        Uri.parse(endpoint),
        body: bytes,
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        return endpoint;
      } else {
        print(
            'Upload failed with status: ${response.statusCode}, body: ${response.body}');
        throw Exception(
            'Failed to upload image: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showErrorToast('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final String? photoUrl = await _uploadImageToS3();

      // Create map with additional profile data
      final Map<String, dynamic> additionalData = {
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
        'address': _addressController.text,
        'dob': _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
        'gender': _gender,
      };

      if (photoUrl != null) {
        additionalData['photoUrl'] = photoUrl;
      }

      if (_userRole != null) {
        additionalData['role'] = _userRole;
      }

      // Update user data in Firestore
      await _firestoreService.updateUserProfile(_userId!, additionalData);

      _showSuccessToast('Profile updated successfully');
    } catch (e) {
      _showErrorToast('Error updating profile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurpleAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.topCenter,
      primaryColor: Colors.green,
      borderRadius: BorderRadius.circular(12),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.topCenter,
      backgroundColor: Colors.red.withOpacity(0.8),
      primaryColor: Colors.red,
      borderRadius: BorderRadius.circular(12),
    );
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
        title: const Text('Profile'),
        backgroundColor: Colors.indigoAccent,
        elevation: 6,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: _getProfileImage(),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          enabled: false,
                          helperText: 'Email cannot be changed',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          icon: Icons.location_on,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectDate,
                          child: IgnorePointer(
                            child: _buildTextField(
                              controller: _dobController,
                              label: 'Date of Birth',
                              icon: Icons.calendar_today,
                              helperText: 'Tap to select date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: _isSaving
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Updating...'),
                                    ],
                                  )
                                : const Text('Update Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_image != null) {
      return FileImage(_image!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return NetworkImage(_currentPhotoUrl!);
    } else {
      // Default profile image when no image is available
      return const AssetImage('assets/images/profile.png');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (label == 'Full Name' && (value == null || value.isEmpty)) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.person, color: Colors.deepPurpleAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: ['Male', 'Female', 'Other'].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _gender = value;
          });
        }
      },
    );
  }
}
