import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false; // Track camera initialization status

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      // Initialize the controller and store the future
      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;

      // Update the state to indicate that the camera is initialized
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera'),
      ),
      body: _isCameraInitialized
          ? CameraPreview(_cameraController)
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: _isCameraInitialized
          ? FloatingActionButton(
              onPressed: () async {
                try {
                  // Ensure the camera is initialized
                  await _initializeControllerFuture;

                  // Capture the image
                  final image = await _cameraController.takePicture();
                  print("Image saved to ${image.path}");

                  // Optionally, display the captured image
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DisplayPictureScreen(imagePath: image.path),
                  // );
                } catch (e) {
                  print("Error taking picture: $e");
                }
              },
              child: Icon(Icons.camera),
            )
          : null, // Hide the button if the camera is not initialized
    );
  }
}