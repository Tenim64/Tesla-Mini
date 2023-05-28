// Packages
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:tesla_mini/globals.dart';
import 'globals.dart' as globals;
import 'package:tesla_mini/tensorflow.dart';
import 'package:tesla_mini/tcpserver.dart';
import 'package:tesla_mini/debugger.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:tesla_mini/imageconverter.dart';

// Process a single image
void focusCamera() async {
  printMessage('Focusing');
  globals.cameraController.setFocusMode(FocusMode.auto);
}

// Start image stream
void startCamera() {
  printMessage('Starting'); // Print in debug console
  globals.cameraController.setFlashMode(FlashMode.off); // Disable camera flash

  recognitionsNotifier.value = 1;

  try {
    // Start image stream
    globals.cameraController.startImageStream((CameraImage image) {
      processImage(image); // Process new image
    });
  } catch (err) {
    printMessage('Already running');
  }

  sendDataTCP('state', 'Starting'); // Send signal to http server
}

// Stop image stream
void stopCamera() {
  printMessage('Stopping'); // Print in debug console

  recognitionsNotifier.value = 0;

  try {
    globals.cameraController.stopImageStream(); // Stop image stream
  } catch (err) {
    printMessage('Wasn\'t running');
  }

  sendDataTCP('state', 'Stopping'); // Send signal to http server
}

void processImage(CameraImage image) async {
  // Don't process multiple images at once
  if (globals.isProcessing) {
    return;
  } else {
    globals.isProcessing = true;
  }

  printMessage("1) New image: ${DateTime.now()}"); // Print in debug console

  // Tensorflow
  try {
    await tfProcessFrame(ImageUtils.convertYUV420ToImage(image));
  } catch (e) {
    printErrorMessage(e);
    exit(0);
  }
}

void sendFrame(photo) async {
  printMessage("Uploading image"); // Print in debug console

  // Convert Camera image to image
  img.Image image = img.Image.fromBytes(
      photo.width, photo.height, photo.planes[0].bytes,
      format: img.Format.bgra);

  // Convert image to jpeg
  Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));

  sendDataTCP("image", jpeg.toString()); // Send jpeg data to http server
}
