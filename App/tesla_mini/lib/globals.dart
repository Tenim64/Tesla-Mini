// ignore_for_file: prefer_typing_uninitialized_variables, invalid_use_of_protected_member

library tesla_mini.globals;

import 'package:flutter/material.dart';

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
