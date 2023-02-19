// Packages
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesla_mini/tensorflow.dart';
import 'package:tesla_mini/ui.dart';
import 'package:wakelock/wakelock.dart';
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
      theme: ThemeData.light().copyWith(
          textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Myanmar Text',
              ),
          primaryTextTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Myanmar Text',
              ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          cupertinoOverrideTheme:
              const CupertinoThemeData(brightness: Brightness.light)),
      home: const HomePage(),
    ),
  );
}
