// Packages
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:core';
import 'package:network_info_plus/network_info_plus.dart';

// Default udp server address
var udpIpAddress = '192.168.1.53';
const udpPort = 8080;
const isUDPServerActive = false;

// Send a test request to udp server
void testHTTP() {
  sendDataUDP('state', 'Testing');
}

// Send data to udp server
void sendDataUDP(String title, String data) {
  if (isUDPServerActive) {
    sendRequestUDP(title, data);
  }
}

Future<void> sendRequestUDP(String title, String data) async {
  // Print in debug console
  debugPrint("Send data: $title");

  // Send to udp
  var udpAddress =
      InternetAddress((await NetworkInfo().getWifiIP()).toString());
  RawDatagramSocket.bind(udpAddress, 0).then((RawDatagramSocket socket) {
    debugPrint('Sending from ${socket.address.address}:${socket.port}');
    int port = udpPort;
    socket.send('Hello from UDP land!\n'.codeUnits, udpAddress, port);
  });
}
