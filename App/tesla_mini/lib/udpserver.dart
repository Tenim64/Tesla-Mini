// Packages
import 'dart:core';
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/globals.dart' as globals;
import 'dart:convert';

// Default udp server address
const isUDPServerActive = true;

String packageMaker(String title, String data) {
  return json.encode({'title': title, 'data': data});
}

// Send a test request to udp server
void testTCP() {
  sendDataTCP('state', 'Testing');
}

// Send data to udp server
void sendDataTCP(String title, String data) {
  if (isUDPServerActive) {
    sendRequestTCP(packageMaker(title, data));
  }
}

Future<void> sendRequestTCP(String data) async {
  // Print in debug console
  printMessage("Send data: $data");

  // Send data
  if (globals.socketTCP == null) {
    await globals.connectSocket();
  }
  try {
    globals.socketTCP?.write(data);
  } catch (e) {
    printErrorMessage("Error occurred: $e");
  }
}
