// ignore_for_file: prefer_typing_uninitialized_variables, invalid_use_of_protected_member

library tesla_mini.globals;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tesla_mini/debugger.dart';

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

const udpIpAddress = '192.168.4.1';
const udpPort = 80;

Socket? socketTCP;
Future<void> connectSocket() async {
  await Socket.connect(udpIpAddress, udpPort,
          timeout: const Duration(milliseconds: 50))
      .then((socket) {
    socketTCP = socket;
  }).catchError(
          (error) => printErrorMessage("Socket connection failed: $error"));
}
