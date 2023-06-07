// ignore_for_file: prefer_typing_uninitialized_variables, invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member, empty_catches, unused_catch_clause

// Packages
library tesla_mini.globals;

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/carfunctions.dart';
import 'dart:convert';
import 'dart:async';

var mainCamera;
late CameraController cameraController;
int currentPageIndex = 0;
late Timer controllerTimer;
int turnAngle = 0;
int speed = 0;

// Tflite
Map<String, Object> recognitions = {};
// 0 = disabled
// 1 = enabled
final recognitionsNotifier = ValueNotifier<int>(0);

var interpreter;
List<String> labels = [];

bool isProcessing = false;

Future<void> updateRecognitions(var inputRecognitions) async {
  recognitions = inputRecognitions;
  recognitionsNotifier.notifyListeners();
  return;
}

// Socket
String packageMaker(String title, String data) {
  return json.encode({'size': '1', 'title': title, 'data': data});
}

String controlsPackageMaker(String speed, String turnAngle) {
  return json.encode({'title': 'control', 'speed': speed, 'turnAngle': turnAngle});
}

bool isTCPServerActive = false;
const tcpIpAddress = '192.168.4.1';
const tcpPort = 80;
bool controlsActive = false;

Socket? socketTCP;
Future<void> connectSocket() async {
  try {
    Socket socket = await Socket.connect(tcpIpAddress, tcpPort, timeout: const Duration(milliseconds: 3000)).catchError(
      (e) {
        isTCPServerActive = false;
        socketTCP = null;

        printErrorMessage("Error occurred: $e");

        setDialog("Error!", e.toString(), "Close", closeDialog, "", closeDialog, 1);
        updateDialog();

        throw e;
      },
    );
    socketTCP = socket;
  } catch (error) {
    throw Exception(error);
  }
}

SocketClient socketClient = SocketClient();

class SocketClient {
  Socket? socket;
  bool connected = false;
  bool processing = false;

  Future<void> connectionCheck() async {
    try {
      if (!connected && socket!.address.address.isEmpty) {
        await connect();
      }
      printMessage("Connection check: connected");
      connected = true;
    } catch (e) {
      printMessage("Connection check: not connected");
      connected = false;
    }
    connectionState = connected ? 1 : -1;
    connectionStateNotifier.notifyListeners();
  }

  Future<void> manualConnectionCheck() async {
    connectionState = 0;
    connectionStateNotifier.notifyListeners();
    // ignore: unused_local_variable
    Timer timeoutTimer = Timer(const Duration(seconds: 2), () {
      connectionState = connected ? 1 : -1;
      connectionStateNotifier.notifyListeners();
    });
    try {
      if (connected) {
        await socket?.close();
      }
    } catch (e) {}
    try {
      await connect();
      connectionState = 1;
      connectionStateNotifier.notifyListeners();
    } catch (e) {
      connectionState = -1;
      connectionStateNotifier.notifyListeners();
      printErrorMessage('Error connecting: $e');
      setDialog("Error connecting!", e.toString(), "Ok", closeDialog, "", closeDialog, 1);
      updateDialog();
    }
  }

  Future<void> connect() async {
    try {
      socket = await Socket.connect(tcpIpAddress, tcpPort, timeout: const Duration(milliseconds: 1000));
      socket?.listen((data) {
        printMessage("Received: ${String.fromCharCodes(data).trim()}");
        processing = false;
        processData(data);
      }, onDone: () {
        printMessage("Disconnected by host");
        connected = false;
        connectionState = connected ? 1 : -1;
        connectionStateNotifier.notifyListeners();
      }, onError: (e) {
        printErrorMessage("Error occurred: $e");

        setDialog("Error!", e.toString(), "Close", closeDialog, "", closeDialog, 1);
        updateDialog();

        connected = false;
        connectionState = connected ? 1 : -1;
        connectionStateNotifier.notifyListeners();
      });
      printMessage('Connected to: ${socket?.remoteAddress.address}:${socket?.remotePort}');
      connected = true;
      processing = false;
    } on SocketException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendData(String jsonData) async {
    if (processing) {
      return;
    }

    if (socket != null) {
      processing = true;

      try {
        socket?.add(utf8.encode('$jsonData\n'));
        printMessage('Sent: $jsonData');
      } catch (e) {
        printErrorMessage('Error sending data: $e');
        disconnect();
        rethrow;
      }
    } else {
      printErrorMessage('Socket not connected.');
    }
  }

  Future<void> processData(response) async {
    try {
      Map<String, dynamic> jsonData = json.decode(utf8.decode(response));
      printMessage(jsonData["title"]);

      if (jsonData["title"] == "battery") {
        processBatteryState(jsonData["data"].toString());
      }
      if (jsonData["title"] == "getControls") {
        if (controlsActive) {
          sendControllerData();
        } else {
          socketClient.sendData(controlsPackageMaker("cancel", "cancel"));
        }
      }
    } catch (e) {
      return;
    }
  }

  Future<void> disconnect() async {
    if (socket != null) {
      try {
        await socket?.close();
        socket = null;
        connected = false;
        printMessage('Disconnected.');
        connectionState = -1;
        connectionStateNotifier.notifyListeners();
      } catch (e) {
        printErrorMessage('Error disconnecting: $e');
        setDialog("Error disconnecting!", e.toString(), "Ok", closeDialog, "", closeDialog, 1);
        updateDialog();
      }
    } else {
      printErrorMessage('Socket not connected.');
    }
  }
}

// Dialog
final dialogNotifier = ValueNotifier<int>(0);

String dialogTitle = "Title", dialogContent = "Content", dialogBtn1Content = "Cancel", dialogBtn2Content = "Ok";
int dialogButtonCount = 2;
Function dialogBtn1Function = () {}, dialogBtn2Function = () {};

void setDialog(title, content, btn1Content, btn1Function, btn2Content, btn2Function, buttonCount) {
  dialogTitle = title;
  dialogContent = content;
  dialogBtn1Content = btn1Content;
  dialogBtn1Function = btn1Function;
  dialogBtn2Content = btn2Content;
  dialogBtn2Function = btn2Function;
  dialogButtonCount = buttonCount;
}

bool dialogActive = false;
void updateDialog() {
  dialogNotifier.value = 1;
}

void closeDialog(context) {
  Navigator.of(context).pop();
  dialogNotifier.value = 0;
  dialogActive = false;
}

final connectionStateNotifier = ValueNotifier<bool>(false);
final batteryStateNotifier = ValueNotifier<bool>(false);
// -1 = disconnected | 0 = connecting/unknown | 1 = connected
int connectionState = -1;
// -1 = low battery | 0 = low charging | 1 = charged
int batteryState = 1;

String carName = "Tesla Mini";
