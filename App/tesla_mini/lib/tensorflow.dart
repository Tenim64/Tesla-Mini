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
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

const modelType = "BelgiumTS";

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
    printMessage(globals.labels);
    printMessage('Tensorflow model loaded');
  } catch (e) {
    printMessage('Error loading model: ${e..toString()}');
  }
}

Future<void> tfProcessFrame(imageLib.Image rawImage) async {
  printTitle("(2) Tensorflow processing");

  // ---- Interpreter Tensors
  var inputTensor = globals.interpreter.getInputTensor(0);
  var outputTensors = globals.interpreter.getOutputTensors();

  // ---- Input values
  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    int padSize = max(inputImage.height, inputImage.width);
    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(
            inputTensor.shape[1], inputTensor.shape[2], ResizeMethod.BILINEAR))
        .build();
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  /// Input
  TensorImage inputImage = TensorImage(inputTensor.type);
  inputImage.loadImage(rawImage);
  inputImage = getProcessedImage(inputImage);
  printMessage("(2.1) Input ready");

  // ---- Output values
  /// Types of output tensors
  List<List<int>> outputShapes = [];
  outputTensors.forEach((tensor) {
    outputShapes.add(tensor.shape);
  });
  // TensorBuffers for output tensors
  TensorBuffer outputLocations =
      TensorBufferFloat(outputShapes[globals.locationsIndex]);
  TensorBuffer outputClasses =
      TensorBufferFloat(outputShapes[globals.classesIndex]);
  TensorBuffer outputScores =
      TensorBufferFloat(outputShapes[globals.scoresIndex]);
  TensorBuffer numLocations = TensorBufferFloat(outputShapes[globals.numIndex]);
  // Outputs map
  Map<int, Object> outputs;
  if (modelType == "BelgiumTS") {
    outputs = {
      globals.locationsIndex: outputLocations.buffer,
      globals.classesIndex: outputClasses.buffer,
      globals.scoresIndex: outputScores.buffer,
      globals.numIndex: numLocations.buffer,
    };
  } else {
    outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };
  }
  printMessage("(2.2) Output ready");

  // ---- Run model
  globals.interpreter.runForMultipleInputs([inputImage.buffer], outputs);
  printMessage("(2.3) Model ran");

  // ---- Set recognitions
  printMessage("(2.4) Output: $outputs");
  globals.recognitions = outputs;
  printMessage("(2.5) Recognitions: ${globals.recognitions}");
  globals.recognitionsNotifier.value = globals.recognitionsNotifier.value * -1;
  printMessage("(2.6) Notifier: ${globals.recognitionsNotifier.value}");

  // Print
  printTitle("(3) Tensorflow processed");
  if (numLocations.getIntValue(0) > 0) {
    printTitle("(4) Detected objects (= ${numLocations.getIntValue(0)}):");
    for (var i = 0; i < numLocations.getIntValue(0); i++) {
      //printMessage("Output $i: ${globals.labels.elementAt(outputClasses.getIntValue(i))} | ${outputScores.getDoubleValue(i) * 100}%");
      if (outputScores.getDoubleValue(i) * 100 > 60) {
        //printMessage("Detected: ${globals.labels.elementAt(outputClasses.getIntValue(i))} | ${outputScores.getDoubleValue(i) * 100}%");
      }
    }
  }
  return;
}

List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
  var recognitionsList = globals.recognitions;
  printMessage("Recognitions (2): ${globals.recognitions}");
  if (recognitionsList == null) return [];

  double factorX = screen.width;
  double factorY = screen.height;

  Color colorPick = Colors.pink;

  printTitle("(5) Updating boxes");
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
