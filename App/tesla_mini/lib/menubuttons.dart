// Packages
import 'package:tesla_mini/camerafunctions.dart';
import 'package:tesla_mini/otherfunctions.dart';

// Button functions
void toggleCameraButton(controller) async {
  if (controller.value.isStreamingImages) {
    stopCamera();
  } else {
    startCamera();
  }
}

void focusButton(controller) {
  focusCamera();
}

void restartButton() {
  restart();
}
