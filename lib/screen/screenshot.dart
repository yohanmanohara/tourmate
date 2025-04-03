import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final List<String> _images = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserImages();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _loadUserImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userGalleryDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gallery')
          .doc('images')
          .get();

      if (userGalleryDoc.exists && userGalleryDoc.data() != null) {
        final data = userGalleryDoc.data()!;
        if (data['images'] != null) {
          setState(() {
            _images.clear();
            _images.addAll(List<String>.from(data['images']));
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final imageUrl = await _uploadImageToS3(File(pickedFile.path));
        if (imageUrl != null) {
          await _saveImageUrlToFirestore(imageUrl);
          await _loadUserImages(); // Reload images
        }
      } catch (e) {
        _showErrorSnackBar('Error uploading image: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadImageToS3(File imageFile) async {
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

      // Generate unique filename
      final uuid = Uuid();
      final fileExtension = path.extension(imageFile.path);
      final uniqueId = uuid.v4();
      final fileName =
          'gallery/${_userId}_${DateTime.now().millisecondsSinceEpoch}_$uniqueId$fileExtension';

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

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
        'X-Amz-Content-SHA256': payloadHash,
        'X-Amz-Date': amzDate,
        'X-Amz-ACL': 'public-read',
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
      print('Upload exception: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get a reference to the user's gallery document
      final galleryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gallery')
          .doc('images');

      // Check if the document exists
      final doc = await galleryRef.get();
      if (doc.exists) {
        // Update existing document with new image URL
        await galleryRef.update({
          'images': FieldValue.arrayUnion([imageUrl]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new document with image URL
        await galleryRef.set({
          'images': [imageUrl],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error saving image reference: $e');
    }
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('My Gallery'),
        backgroundColor:
            Colors.grey[100], // Changed from Theme.of(context).primaryColor
        foregroundColor: Colors
            .black87, // Adding this to ensure text is visible on light background
        elevation: 0, // Remove shadow for a cleaner look
        actions: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: _pickAndUploadImage,
            tooltip: 'Add new photo',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Your gallery is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text('Add Photos'),
                        onPressed: _pickAndUploadImage,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showImagePreview(context, _images[index]);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 3,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image,
                                      color: Colors.red),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteImage(imagePath);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteImage(String imageUrl) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Image'),
            content: Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Remove from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gallery')
          .doc('images')
          .update({
        'images': FieldValue.arrayRemove([imageUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Note: This doesn't delete from S3 (would require an additional API)
      // To fully delete from S3, you'd need to implement a server-side function

      await _loadUserImages();
    } catch (e) {
      _showErrorSnackBar('Error deleting image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
