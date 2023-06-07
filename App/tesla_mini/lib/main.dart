// Packages
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesla_mini/globals.dart' as globals;
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

  try {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    globals.mainCamera = cameras.first;
  } catch (e) {
    printErrorMessage(e);
  }
  // App
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          sliderTheme: ThemeData.light().sliderTheme.copyWith(
              thumbColor: const Color(0xFF7A7A7A),
              overlayColor: const Color(0x00000000),
              activeTrackColor: const Color(0xFFA5A5A5),
              inactiveTrackColor: const Color(0xFFA5A5A5),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 40,
                disabledThumbRadius: 40,
                elevation: 0,
                pressedElevation: 0,
              ),
              trackHeight: 10),
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
          cupertinoOverrideTheme: const CupertinoThemeData(brightness: Brightness.light)),
      home: const HomePage(),
    ),
  );
}
