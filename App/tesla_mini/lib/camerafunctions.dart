// Packages
import 'package:camera/camera.dart';
import 'package:tesla_mini/globals.dart';
import 'package:tesla_mini/tensorflow.dart';
import 'package:tesla_mini/udpserver.dart';

import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

// Process a single image
void focusCamera(CameraController controller) async {
  debugPrint('Focusing');
  controller.setFocusMode(FocusMode.auto);
}

// Start image stream
void startCamera(CameraController controller) {
  debugPrint('Starting'); // Print in debug console
  controller.setFlashMode(FlashMode.off); // Disable camera flash

  recognitionsNotifier.value = 1;

  try {
    // Start image stream
    controller.startImageStream((CameraImage image) {
      processImage(image); // Process new image
    });
  } catch (err) {
    debugPrint('Already running');
  }

  sendDataUDP('state', 'Starting'); // Send signal to http server
}

// Stop image stream
void stopCamera(CameraController controller) {
  debugPrint('Stopping'); // Print in debug console

  recognitionsNotifier.value = 0;

  try {
    controller.stopImageStream(); // Stop image stream
  } catch (err) {
    debugPrint('Wasn\'t running');
  }

  sendDataUDP('state', 'Stopping'); // Send signal to http server
}

bool isProcessing = false;
void processImage(CameraImage image) async {
  // Don't process multiple images at once
  if (isProcessing) {
    return;
  } else {
    isProcessing = true;
  }

  debugPrint("1) New image: ${DateTime.now()}"); // Print in debug console

  // Tensorflow
  await tfProcessFrame(image);

  isProcessing = false;
}

void sendFrame(photo) async {
  debugPrint("Uploading image"); // Print in debug console

  // Convert Camera image to image
  img.Image image = img.Image.fromBytes(
      photo.width, photo.height, photo.planes[0].bytes,
      format: img.Format.bgra);

  // Convert image to jpeg
  Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));

  sendDataUDP("image", jpeg.toString()); // Send jpeg data to http server
}
