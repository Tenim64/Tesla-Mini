// Packages
import 'package:flutter/foundation.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:tesla_mini/debugger.dart';

// Default http server address
const httpServerAddress = 'http://192.168.1.53:8080';
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

Future<http.Response> sendRequestHTTP(String title, String data) {
  // Print in debug console
  printMessage("Send data: $title");

  // Post to http server
  return http.post(
    Uri.parse(httpServerAddress),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: convert.jsonEncode(<String, String>{
      'title': title,
      'data': data,
    }),
  );
}
