// Packages
import 'package:tesla_mini/camerafunctions.dart';
import 'package:tesla_mini/otherfunctions.dart';
import 'package:flutter/foundation.dart';

// Button functions
void toggleCameraButton(controller) async {
  if (controller.value.isStreamingImages) {
    stopCamera(controller);
  } else {
    startCamera(controller);
  }
}

void focusButton(controller) {
  focusCamera(controller);
}

void restartButton() {
  restart();
}
