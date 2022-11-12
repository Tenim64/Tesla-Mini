// Packages
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'globals.dart' as globals;
import 'package:tesla_mini/debugger.dart';

// Load the models
void tfLoadModel(modelName) async {
  // Extra check that Tensorflow closed properly last time
  Tflite.close();
  // Load models
  String? res = await Tflite.loadModel(
      model: "assets/model.tflite", labels: "assets/labels.txt");
  printMessage('Tensorflow models: $res');
}

double round(inputValue, decimals) {
  return double.parse((inputValue).toStringAsFixed(decimals));
}

Future<void> tfProcessFrame(CameraImage image) async {
  printTitle("(2) Tensorflow processing");

  globals.recognitions = await Tflite.detectObjectOnFrame(
    bytesList: image.planes.map((plane) {
      return plane.bytes;
    }).toList(),
    imageHeight: image.height,
    imageWidth: image.width,
    imageMean: 127.5,
    imageStd: 127.5,
    numResultsPerClass: 3,
    threshold: 0.6,
    model: "SSDMobileNet",
  );

  // ---- Set recognitions
  globals.recognitions = outputs;
  globals.recognitionsNotifier.value = globals.recognitionsNotifier.value * -1;

  printTitle("(3) Tensorflow processed");
  if (globals.recognitions != null) {
    printTitle("(4) Detected objects:");
    for (int i = 0; i < numLocations.getIntValue(0); i++) {
      if (outputScores.getDoubleValue(i) * 100 > 60) {
        printMessage(
            "Detected: ${globals.labels.elementAt(outputClasses.getIntValue(i))} | ${outputScores.getDoubleValue(i) * 100}%");
        printMessage(
            globals.labels.elementAt(outputClasses.getIntValue(i + 1)));
        printMessage(outputLocations.buffer.asByteData());
        printMessage(
            outputLocations.buffer.asByteData().buffer.asFloat32List());
      }
    }
  }

  return;
}

List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
  var recognitionsList = globals.recognitions;
  if (recognitionsList == null) return [];

  double factorX = screen.width;
  double factorY = screen.height;

  Color colorPick = Colors.pink;

  printMessage("(updated boxes)");
  return recognitionsList.map<Widget>((result) {
    return Positioned(
      left: result["rect"]["x"] * factorX,
      top: result["rect"]["y"] * factorY,
      width: result["rect"]["w"] * factorX,
      height: result["rect"]["h"] * factorY,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: Colors.pink, width: 2.0),
        ),
        child: Text(
          "${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            background: Paint()..color = colorPick,
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }).toList();
}
