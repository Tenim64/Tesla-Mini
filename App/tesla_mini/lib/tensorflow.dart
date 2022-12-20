// Packages
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tesla_mini/udpserver.dart';
import 'globals.dart' as globals;
import 'package:tesla_mini/debugger.dart';
import 'package:image/image.dart' as imageLib;
import 'package:firebase_core/firebase_core.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

const detectionThreshold = 40;

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
    //printMessage(globals.labels);
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
  TensorBuffer outputLocations = TensorBufferFloat(outputShapes[1]);
  TensorBuffer outputClasses = TensorBufferFloat(outputShapes[3]);
  TensorBuffer outputScores = TensorBufferFloat(outputShapes[0]);
  TensorBuffer outputCount = TensorBufferFloat(outputShapes[2]);
  // Outputs map
  Map<int, Object> outputs = {
    0: outputScores.buffer,
    1: outputLocations.buffer,
    2: outputCount.buffer,
    3: outputClasses.buffer,
  };
  printMessage("(2.2) Output ready");

  // ---- Run model
  globals.interpreter.runForMultipleInputs([inputImage.buffer], outputs);
  printMessage("(2.3) Model ran");

  // ---- Set recognitions
  Map<String, Object> recognitions = {
    "locations": outputLocations.getDoubleList(),
    "classes": outputClasses.getDoubleList(),
    "scores": outputScores.getDoubleList(),
    "count": outputCount.getIntValue(0),
  };
  /*
  printMessage("Locations: ${outputLocations.getDoubleList()}");
  printMessage("Classes: ${outputClasses.getDoubleList()}");
  printMessage("Scores: ${outputScores.getDoubleList()}");
  printMessage("Count: ${outputCount.getIntValue(0)}");
  */
  await globals.updateRecognitions(recognitions);

  // ---- Send data
  if (outputCount.getIntValue(0) > 0) {
    for (var i = 0; i < outputCount.getIntValue(0); i++) {
      if (outputScores.getDoubleValue(i) * 100 > detectionThreshold) {
        sendDataTCP("recognition",
            globals.labels.elementAt(outputClasses.getIntValue(i)));
      }
    }
  }

  // Print
  printTitle("(3) Tensorflow processed");
  if (outputCount.getIntValue(0) > 0) {
    printTitle("(4) Detected objects:");
    for (var i = 0; i < outputCount.getIntValue(0); i++) {
      if (outputScores.getDoubleValue(i) * 100 > detectionThreshold) {
        printMessage(
            "${globals.labels.elementAt(outputClasses.getIntValue(i))} | ${outputScores.getDoubleValue(i) * 100}%");
      }
    }
  }
  return;
}

List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
  Map<String, Object> recognitions = globals.recognitions;
  if (recognitions.isEmpty) return [];
  printTitle("(5) Updating boxes");

  List<double> rawLocations = recognitions["locations"] as List<double>;
  List<double> classes = recognitions["classes"] as List<double>;
  List<double> scores = recognitions["scores"] as List<double>;
  int count = recognitions["count"] as int;
  printMessage("(5.1) Raw input ready");

  List<Map> locations = [];
  for (var i = 0; i < count; i += 4) {
    Map location = {};
    location["x"] = rawLocations[i];
    location["y"] = rawLocations[i + 1];
    location["width"] = rawLocations[i + 2];
    location["height"] = rawLocations[i + 3];
    locations.add(location);
    if (i == 0) {
      printMessage(
          "location at: (${location["x"]}, ${location["y"]}) width:${location["width"]}, height:${location["height"]}");
    }
  }
  printMessage("(5.2) Locations ready");

  double factorX = screen.width;
  double factorY = screen.height;
  printMessage("(5.3) Screen size ready ($factorX, $factorY)");

  Color colorPick = Colors.pink;

  List<Widget> boxes = [];
  // Iterate over possible detections
  for (var i = 0; i < count; i++) {
    Widget box;
    // Check if score is higher than 60, otherwise skip
    if (scores[i] * 100 < detectionThreshold) {
      continue;
    }
    box = Positioned(
      left: locations[i]["x"] * factorX,
      top: locations[i]["y"] * factorY,
      width: locations[i]["width"] * factorX,
      height: locations[i]["height"] * factorY,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: Colors.pink, width: 2.0),
        ),
        child: Text(
          "${globals.labels.elementAt(classes[i].toInt())} ${(scores[i] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            background: Paint()..color = colorPick,
            color: Colors.black,
            fontSize: 18.0,
          ),
        ),
      ),
    );
    boxes.add(box);
  }
  printMessage("(5.3) Boxes ready");
  return boxes;
}
