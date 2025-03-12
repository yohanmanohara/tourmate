import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  // List of image paths (from local assets and URLs)
  final List<String> images = [
    'assets/company.png',
    'assets/google.png',
    'assets/ruins.jpg',
    'assets/city.jpg',
    // Add more image paths as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],  // Adding a light background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 16.0, // Horizontal space between items
            mainAxisSpacing: 16.0,  // Vertical space between items
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Show image preview on tap
                _showImagePreview(context, images[index]);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0), // Rounded corners for images
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: Offset(0, 4), // Shadow direction
                      ),
                    ],
                  ),
                  child: images[index].startsWith('http') // Check if it's a URL
                      ? Image.network(
                          images[index], // Load image from network
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          images[index], // Load image from assets
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Function to show image preview in a Dialog
  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners for the dialog
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
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
            ],
          ),
        );
      },
    );
  }
}
