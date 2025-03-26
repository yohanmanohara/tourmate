import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditDestinationScreen extends StatefulWidget {
  final String? destinationId;

  const EditDestinationScreen({
    Key? key,
    this.destinationId,
  }) : super(key: key);

  @override
  State<EditDestinationScreen> createState() => _EditDestinationScreenState();
}

class _EditDestinationScreenState extends State<EditDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _category = 'Historical';
  List<String> _features = [];
  List<String> _existingImageUrls = [];
  List<File> _newImageFiles = [];
  bool _isLoading = false;
  bool _isEdit = false;

  final List<String> _categories = [
    'Historical',
    'Nature',
    'Cultural',
    'Urban',
    'Adventure'
  ];

  final List<String> _featureOptions = [
    'Family-friendly',
    'Guided tours',
    'Wheelchair accessible',
    'Free Wi-Fi',
    'Restaurant on site',
    'Gift shop',
    'Parking available',
    'Public transport nearby',
    'Photography allowed',
    'Pet-friendly'
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.destinationId != null;
    if (_isEdit) {
      _loadDestinationData();
    }
  }

  Future<void> _loadDestinationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('destinations')
          .doc(widget.destinationId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _locationController.text = data['location'] ?? '';

        if (data['category'] != null) {
          setState(() {
            _category = data['category'];
          });
        }

        if (data['features'] != null) {
          setState(() {
            _features = List<String>.from(data['features']);
          });
        }

        if (data['images'] != null) {
          setState(() {
            _existingImageUrls = List<String>.from(data['images']);
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading destination data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImageFiles
            .addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];
    final uuid = Uuid();

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

    for (var imageFile in _newImageFiles) {
      try {
        // Generate unique filename with UUID to prevent conflicts
        final fileExtension = path.extension(imageFile.path);
        final uniqueId = uuid.v4();
        final fileName =
            'destinations/${DateTime.now().millisecondsSinceEpoch}_$uniqueId$fileExtension';

        // Read file as bytes
        final bytes = await imageFile.readAsBytes();

        // Prepare the URL for the S3 bucket
        final endpoint =
            'https://$bucketName.s3.$awsRegion.amazonaws.com/$fileName';

        // Get current date and time in UTC
        final now = DateTime.now().toUtc();

        // Format date for AWS signature (YYYYMMDD)
        final dateStamp =
            '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

        // Format amzDate (ISO8601 basic format: YYYYMMDD'T'HHMMSS'Z')
        final amzDate =
            '${dateStamp}T${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z';

        // Create AWS headers for authentication
        final contentType = 'image/${fileExtension.substring(1)}';
        final payloadHash = sha256.convert(bytes).toString();

        final headers = {
          'host': '$bucketName.s3.$awsRegion.amazonaws.com',
          'content-type': contentType,
          'x-amz-content-sha256': payloadHash,
          'x-amz-date': amzDate,
          'x-amz-acl': 'public-read', // Make the file publicly accessible
        };

        // Get signed headers (must be sorted)
        final signedHeadersKeys = headers.keys.toList()..sort();
        final signedHeadersStr = signedHeadersKeys.join(';');

        // Create canonical headers (must be sorted by key)
        final canonicalHeaders =
            signedHeadersKeys.map((key) => '$key:${headers[key]}\n').join();

        // Generate AWS Signature Version 4
        final canonicalUri = '/$fileName';
        final canonicalQueryString = '';

        // Create canonical request
        final canonicalRequest = [
          'PUT',
          canonicalUri,
          canonicalQueryString,
          canonicalHeaders,
          signedHeadersStr,
          payloadHash,
        ].join('\n');

        // String to sign
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

        // Calculate signature
        // Step 1: Create signing key
        final kSecret = utf8.encode('AWS4$awsSecretKey');
        final kDate =
            Hmac(sha256, kSecret).convert(utf8.encode(dateStamp)).bytes;
        final kRegion =
            Hmac(sha256, kDate).convert(utf8.encode(awsRegion)).bytes;
        final kService = Hmac(sha256, kRegion).convert(utf8.encode('s3')).bytes;
        final kSigning =
            Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;

        // Step 2: Calculate signature
        final signature = Hmac(sha256, kSigning)
            .convert(utf8.encode(stringToSign))
            .toString();

        // Create authorization header
        final authorization =
            '$algorithm Credential=$awsAccessKey/$credentialScope, ' +
                'SignedHeaders=$signedHeadersStr, Signature=$signature';

        // Prepare headers for the request (with proper case)
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
          // S3 returns 200 on successful PUT
          imageUrls.add(endpoint);
        } else {
          print(
              'Upload failed with status: ${response.statusCode}, body: ${response.body}');
          throw Exception(
              'Failed to upload image: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Upload exception: $e');
        throw Exception('Error uploading image: $e');
      }
    }

    return imageUrls;
  }

  Future<void> _saveDestination() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload any new images
      List<String> newImageUrls = [];
      if (_newImageFiles.isNotEmpty) {
        newImageUrls = await _uploadImages();
      }

      // Combine existing and new image URLs
      final allImages = [..._existingImageUrls, ...newImageUrls];

      // Create destination data
      final destinationData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _category,
        'location': _locationController.text,
        'features': _features,
        'images': allImages,
        'updatedAt': FieldValue.serverTimestamp(),
        'coordinates': {
          'latitude': 0.0, // Replace with actual coordinates when implemented
          'longitude': 0.0, // Replace with actual coordinates when implemented
        },
      };

      // Add createdAt and averageRating for new destinations
      if (!_isEdit) {
        destinationData['createdAt'] = FieldValue.serverTimestamp();
        destinationData['averageRating'] = 0.0;
      }

      // Save to Firestore
      final destinationsRef =
          FirebaseFirestore.instance.collection('destinations');

      if (_isEdit) {
        await destinationsRef.doc(widget.destinationId).update(destinationData);
      } else {
        await destinationsRef.add(destinationData);
      }

      if (mounted) {
        _showSuccessSnackBar(_isEdit
            ? 'Destination updated successfully'
            : 'Destination added successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar('Error saving destination: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Destination' : 'Add New Destination'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'Preview',
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/destination-details',
                  arguments: widget.destinationId,
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Destination Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _category,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _category = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Features
                    const Text(
                      'Features',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _featureOptions.map((feature) {
                        final isSelected = _features.contains(feature);
                        return FilterChip(
                          label: Text(feature),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _features.add(feature);
                              } else {
                                _features.remove(feature);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Images Section
                    const Text(
                      'Images',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Existing Images
                    if (_existingImageUrls.isNotEmpty) ...[
                      const Text('Current Images:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImageUrls.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          _existingImageUrls[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _removeExistingImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // New Images
                    if (_newImageFiles.isNotEmpty) ...[
                      const Text('New Images:'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _newImageFiles.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_newImageFiles[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeNewImage(index),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Add Images Button
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Images'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveDestination,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                          _isEdit ? 'Update Destination' : 'Add Destination'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
