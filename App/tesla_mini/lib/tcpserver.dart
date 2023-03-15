// Packages
// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:async';
import 'dart:core';
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/globals.dart' as globals;
import 'dart:convert';

String packageMaker(String title, String data) {
  return json.encode({'title': title, 'data': data});
}

// Send a test request to tcp server
void testTCP() {
  sendDataTCP('state', 'Testing');
}

Future<bool> checkTCPServerStatus() async {
  globals.connectionState = 0;
  globals.connectionStateNotifier.notifyListeners();
  Timer timeoutTimer = Timer(const Duration(seconds: 2), () {
    globals.connectionState = globals.isTCPServerActive ? 1 : -1;
    globals.connectionStateNotifier.notifyListeners();
  });
  try {
    // Connect to socket
    if (globals.socketTCP != null) {
      await globals.socketTCP?.close();
    }
    await globals.connectSocket();
    globals.socketTCP?.write(packageMaker("get", "connection"));
    globals.isTCPServerActive = true;
  } catch (e) {
    if (!e.toString().contains("errno = 104")) {
      globals.isTCPServerActive = false;
    }
  }

  if (!timeoutTimer.isActive) {
    globals.connectionState = globals.isTCPServerActive ? 1 : -1;
    globals.connectionStateNotifier.notifyListeners();
  }
  return globals.isTCPServerActive;
}

// Send data to tcp server
Future<void> sendDataTCP(String title, String data) async {
  if (globals.isTCPServerActive || await checkTCPServerStatus()) {
    sendRequestTCP(packageMaker(title, data));
  }
}

Future<void> sendRequestTCP(String data) async {
  try {
    // Connect to socket
    if (globals.socketTCP == null) {
      await globals.connectSocket();
    }
    // Send data
    globals.socketTCP?.write(data);
    globals.socketTCP?.close();
    if (jsonDecode(data)['data'] == 'Testing') {
      // Print in debug console
      printMessage("Data sent: $data");
      globals.setDialog("Data sent!", "A connection was made/found and data has been sent", "Ok", globals.closeDialog, "", globals.closeDialog, 1);
      globals.updateDialog();
    }
  } catch (e) {
    printErrorMessage("Error occurred: $e");

    globals.setDialog("Error!", e.toString(), "Close", globals.closeDialog, "", globals.closeDialog, 1);
    globals.updateDialog();
  }
  globals.socketTCP = null;
}

// Get data from tcp server
Future<String> getDataTCP(String title, String data) async {
  // Yet to come
  return getRequestTCP(packageMaker(title, data));
}

Future<String> getRequestTCP(String data) async {
  // Yet to come
  return "";
}
