// Packages
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'globals.dart' as globals;
import 'package:tesla_mini/debugger.dart';

Future<void> tfLoadFirebase() async {
  await Firebase.initializeApp();
  printMessage('Firebase active');
}

// Load the models
void tfLoadModel(modelName) async {
  // Load Firebase models
  FirebaseCustomModel model = await FirebaseModelDownloader.instance
      .getModel(modelName, FirebaseModelDownloadType.latestModel);
  var localModelPath = model.file.path;
  printMessage('Loaded model: ${model.name}');

  // Extra check that Tensorflow closed properly last time
  Tflite.close();
  // Load models
  String? res = await Tflite.loadModel(
      model: "assets/model.tflite", labels: "assets/labels.txt");
  printMessage('Tensorflow models: $res');
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
    threshold: 0.4,
    model: "SSDMobileNet",
  );

  globals.recognitionsNotifier.value = globals.recognitionsNotifier.value * -1;

  printTitle("(3) Tensorflow processed");
  if (globals.recognitions != null) {
    printTitle("(4) Detected objects:");
    printMessage(globals.recognitions.map((result) {
      return "${result['detectedClass']} | ${result['rect']['x']}, ${result['rect']['y']} | ${result['rect']['w']}, ${result['rect']['h']}}";
    }).toString());
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
