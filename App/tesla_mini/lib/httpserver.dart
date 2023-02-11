// Packages
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:tesla_mini/debugger.dart';
import 'package:tesla_mini/globals.dart' as globals;

// Default http server address
const httpServerAddress = 'http://192.168.4.1';
const isHTTPServerActive = false;

// Send a test request to http server
void testHTTP() {
  sendDataHTTP('state', 'Testing');
}

// Send data to http server
void sendDataHTTP(String title, String data) {
  if (isHTTPServerActive) {
    sendRequestHTTP(title, data);
  }
}

Future<void> sendRequestHTTP(String title, String data) async {
  // Print in debug console
  printMessage("Send data: $title");

  try {
    // Post to http server
    await http.post(
      Uri.parse(httpServerAddress),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, String>{
        'title': title,
        'data': data,
      }),
    );
  } catch (e) {
    printErrorMessage("Error occurred: $e");
    globals.setDialog("Error!", e.toString(), "Close", globals.closeDialog, "",
        globals.closeDialog, 1);
    globals.updateDialog();
  }
}
