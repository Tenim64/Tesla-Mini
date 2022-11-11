// Packages
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesla_mini/tensorflow.dart';
import 'package:tesla_mini/ui.dart';
import 'package:wakelock/wakelock.dart';
import 'package:tflite/tflite.dart';
import 'package:tesla_mini/debugger.dart';

// List for cameras
List<CameraDescription> cameras = [];

// Main app
Future<void> main() async {
  printMessage('Starting software');

  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    printErrorMessage(details.exception.toString()); // the uncaught exception
    printErrorMessage(details.stack.toString()); // the stack trace at the time
  };

  Wakelock.enable();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  // App
  runApp(
    MaterialApp(
      theme: ThemeData.dark().copyWith(
          textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            textStyle: const TextStyle(
              fontSize: 20,
            )),
      )),
      home: CameraScreen(
        camera: firstCamera,
      ),
    ),
  );
}

// Create the camera screen
class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
      // Disable audio recording
      enableAudio: false,
      // Format of the images
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    // Load Tensorflow models
    tfLoadModel('Android');
  }

  @override
  void dispose() {
    // Dispose app
    super.dispose();
    // Dispose of the controller when the widget is disposed.
    _controller.stopImageStream();
    _controller.dispose();
    // Close Tensorflow
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Interface(
        pInitializeControllerFuture: _initializeControllerFuture,
        pController: _controller);
  }
}
