// Packages
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:tesla_mini/debugger.dart';
import 'package:image/image.dart' as imageLib;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

Future<void> tfLoadFirebase() async {
  await Firebase.initializeApp();
  printMessage('Firebase active');
}

// Load the models
void tfLoadModel(modelName) async {
  // Load Firebase models
  /*
  FirebaseCustomModel model = await FirebaseModelDownloader.instance
      .getModel(modelName, FirebaseModelDownloadType.latestModel);
  var localModelPath = model.file.path;
  printMessage('Found model: ${model.name}');
  */

  // Extra check that Tensorflow closed properly last time
  if (globals.interpreter != null) {
    globals.interpreter.close();
  }
  // Load models
  try {
    globals.interpreter = await tfl.Interpreter.fromAsset('model.tflite');
    globals.labels = await FileUtil.loadLabels("assets/labels.txt");
    printMessage('Tensorflow model loaded');
  } catch (e) {
    printMessage('Error loading model: ${e..toString()}');
  }
}

Future<void> tfProcessFrame(imageLib.Image rawImage) async {
  printTitle("(2) Tensorflow processing");

  // ---- Constants
  /// Input size of image (height = width = 300)
  const int INPUT_SIZE = 300;

  /// Result score threshold
  const double THRESHOLD = 0.5;

  // ---- Input values
  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    int padSize = max(inputImage.height, inputImage.width);
    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .build();
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  List<Object> inputs = [
    (getProcessedImage(TensorImage.fromImage(rawImage))).buffer
  ];

  // ---- Output values
  var outputTensors = globals.interpreter.getOutputTensors();

  /// Types of output tensors
  List<List<int>> outputShapes = [];
  outputTensors.forEach((tensor) {
    outputShapes.add(tensor.shape);
  });
  // TensorBuffers for output tensors
  TensorBuffer outputLocations = TensorBufferFloat(outputShapes[0]);
  TensorBuffer outputClasses = TensorBufferFloat(outputShapes[1]);
  TensorBuffer outputScores = TensorBufferFloat(outputShapes[2]);
  TensorBuffer numLocations = TensorBufferFloat(outputShapes[3]);
  // Outputs map
  Map<int, Object> outputs = {
    0: outputLocations.buffer,
    1: outputClasses.buffer,
    2: outputScores.buffer,
    3: numLocations.buffer,
  };

  // ---- Run model
  globals.interpreter.runForMultipleInputs(inputs, outputs);

  // ---- Set recognitions
  globals.recognitionsNotifier.value = globals.recognitionsNotifier.value * -1;

  // Print
  printTitle("(3) Tensorflow processed");
  if (numLocations.getIntValue(0) > 0) {
    printTitle("(4) Detected objects:");
    printMessage(outputLocations);
    for (int i = 0; i < numLocations.getIntValue(0); i++) {
      printMessage(
          "Detected: ${globals.labels.elementAt(outputClasses.getIntValue(i))} | ${outputScores.getDoubleValue(i) * 100}%");
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

  printMessage("(updated boxes) | List: ${recognitionsList.toString()}");
  return recognitionsList.map<Widget>((result) {
    if (result['confidenceInClass'] * 100 < 60) {
      return const Positioned(
          left: 0, top: 0, width: 0, height: 0, child: SizedBox.shrink());
    }
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
