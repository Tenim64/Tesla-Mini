// Packages
import 'dart:core';
import 'package:tesla_mini/globals.dart' as globals;
import 'package:tesla_mini/tcpserver.dart';

Future<void> getSetBatteryState() async {
  String response = await getDataTCP("get", "batterystate");
  response = "Charged";
  switch (response) {
    case "Charged":
      globals.batteryState = 1;
      break;
    case "Charging":
      globals.batteryState = 0;
      break;
    case "Low battery":
      globals.batteryState = -1;
      break;
    default:
      globals.batteryState = -1;
      break;
  }
  globals.batteryStateNotifier.value = !globals.batteryStateNotifier.value;
}

void setSpeed(double speed) {
  sendDataTCP("control", "speed: $speed");
}

void setTurnPercentage(double percentage) {
  sendDataTCP("control", "turn: $percentage");
}
