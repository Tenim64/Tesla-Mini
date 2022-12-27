// ignore_for_file: prefer_typing_uninitialized_variables, invalid_use_of_protected_member

// Packages
library tesla_mini.globals;

import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tesla_mini/debugger.dart';

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
const udpIpAddress = '192.168.4.1';
const udpPort = 80;

Socket? socketTCP;
Future<void> connectSocket() async {
  try {
    Socket socket = await Socket.connect(udpIpAddress, udpPort,
        timeout: const Duration(milliseconds: 1000));
    socketTCP = socket;
  } catch (error) {
    throw Exception(error);
  }
}

// Dialog
final dialogNotifier = ValueNotifier<int>(0);
String dialogTitle = "Title",
    dialogContent = "Content",
    dialogBtn1Content = "Cancel",
    dialogBtn2Content = "Ok";
int dialogButtonCount = 2;
Function dialogBtn1Function = () {}, dialogBtn2Function = () {};

void setDialog(title, content, btn1Content, btn1Function, btn2Content,
    btn2Function, buttonCount) {
  dialogTitle = title;
  dialogContent = content;
  dialogBtn1Content = btn1Content;
  dialogBtn1Function = btn1Function;
  dialogBtn2Content = btn2Content;
  dialogBtn2Function = btn2Function;
  dialogButtonCount = buttonCount;
}

void updateDialog() {
  dialogNotifier.value += 1;
}

void closeDialog(context) {
  Navigator.of(context).pop();
  dialogNotifier.value -= 1;
}
