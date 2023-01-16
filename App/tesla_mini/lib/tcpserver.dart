// Packages
import 'dart:core';
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/globals.dart' as globals;
import 'dart:convert';

// Default tcp server address
const isTCPServerActive = true;

String packageMaker(String title, String data) {
  return json.encode({'title': title, 'data': data});
}

// Send a test request to tcp server
void testTCP() {
  sendDataTCP('state', 'Testing');
}

// Send data to tcp server
void sendDataTCP(String title, String data) {
  if (isTCPServerActive) {
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
    if (jsonDecode(data)['data'] == 'Testing') {
      // Print in debug console
      printMessage("Data sent: $data");
      globals.setDialog(
          "Data sent!",
          "A connection was made/found and data has been sent",
          "Ok",
          globals.closeDialog,
          "",
          globals.closeDialog,
          1);
      globals.updateDialog();
    }
  } catch (e) {
    printErrorMessage("Error occurred: $e");
    globals.setDialog("Error!", e.toString(), "Close", globals.closeDialog, "",
        globals.closeDialog, 1);
    globals.updateDialog();
  }
}
