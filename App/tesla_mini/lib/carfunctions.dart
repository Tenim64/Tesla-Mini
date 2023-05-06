// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
// Packages
import 'dart:core';
import 'package:tesla_mini/globals.dart' as globals;
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/tcpserver.dart';

Future<void> getCarState() async {
  await globals.socketClient.manualConnectionCheck();
  getSetBatteryState();
}

void getSetBatteryState() {
  globals.socketClient.sendData(globals.packageMaker("get", "battery"));
}

void processBatteryState(response) {
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

void sendControllerData() {
  globals.socketClient.sendData(globals.controlsPackageMaker(
      globals.speed.toString(), globals.turnAngle.toString()));
}

void setSpeed(int speed) {
  globals.speed = speed;
  sendControllerData();
}

void setTurnPercentage(int percentage) {
  globals.turnAngle = percentage;
  sendControllerData();
}
