// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
// Packages
import 'dart:core';
import 'package:tesla_mini/globals.dart' as globals;
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/tcpserver.dart';

Future<void> getCarState() async {
  await checkTCPServerState();
  await getSetBatteryState();
}

Future<void> getSetBatteryState() async {
  String response = await getDataTCP("get", "battery");
  switch (response) {
    case "charged":
      globals.batteryState = 1;
      break;
    case "charging":
      globals.batteryState = 0;
      break;
    case "low":
      globals.batteryState = -1;
      break;
    default:
      globals.batteryState = -1;
      break;
  }
  printMessage("batteryState: $response => ${globals.batteryState}");
  globals.batteryStateNotifier.notifyListeners();
}

void setSpeed(double speed) {
  sendDataTCP("control", "speed: $speed");
}

void setTurnPercentage(double percentage) {
  sendDataTCP("control", "turn: $percentage");
}
