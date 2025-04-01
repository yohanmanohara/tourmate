import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  bool _isRecording = false;
  FlashMode _flashMode = FlashMode.off;
  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isEmpty) {
      debugPrint('No cameras available');
      return;
    }

    // Initialize with back camera first
    _controller = CameraController(
      _cameras!.firstWhere(
        (camera) => camera.lensDirection == _direction,
        orElse: () => _cameras!.first,
      ),
      ResolutionPreset.high,
      enableAudio: true,
    );

    _controller!.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() => _isReady = true);
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _toggleCameraDirection() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isReady = false;
      _direction = _direction == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });

    await _controller!.dispose();

    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });

    await _controller!.setFlashMode(_flashMode);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile picture = await _controller!.takePicture();
      
      // Here you can save the picture or display a preview
      final File imageFile = File(picture.path);
      debugPrint('Picture saved to ${imageFile.path}');
      
      // Optionally show a preview or navigate to a preview page
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(imagePath: picture.path),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      try {
        final XFile video = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        debugPrint('Video saved to ${video.path}');
        
        // Optionally show a preview or navigate to a preview page
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoPreviewPage(videoPath: video.path),
          ),
        );
      } on CameraException catch (e) {
        debugPrint('Error stopping video recording: $e');
      }
    } else {
      try {
        final Directory extDir = await getTemporaryDirectory();
        final String dirPath = '${extDir.path}/Movies/flutter_camera';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.mp4';

        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
      } on CameraException catch (e) {
        debugPrint('Error starting video recording: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameras == null || _cameras!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No cameras available')),
      );
    }

    if (!_isReady || _controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: Icon(
                _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: _toggleCameraDirection,
                ),
                GestureDetector(
                  onTap: _isRecording ? null : _takePicture,
                  onLongPress: _toggleRecording,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  onPressed: () {
                    // Implement gallery access here
                  },
                ),
              ],
            ),
          ),
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Recording',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Preview page for captured images
class PreviewPage extends StatelessWidget {
  final String imagePath;

  const PreviewPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          // Save the image permanently or return the path
          Navigator.of(context).pop(imagePath);
        },
      ),
    );
  }
}

// Preview page for recorded videos
class VideoPreviewPage extends StatelessWidget {
  final String videoPath;

  const VideoPreviewPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Preview')),
      body: Center(
        child: VideoPlayer(File(videoPath) as VideoPlayerController), // You'll need a video player package
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () {
          // Save the video permanently or return the path
          Navigator.of(context).pop(videoPath);
        },
      ),
    );
  }
}