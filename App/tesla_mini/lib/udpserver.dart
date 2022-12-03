// Packages
import 'dart:io';
import 'dart:core';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tesla_mini/debugger.dart';

// Default udp server address
var udpIpAddress = '192.168.1.53';
const udpPort = 8080;
const isUDPServerActive = false;

Future<void> scanNetwork() async {
  await (NetworkInfo().getWifiIP()).then(
    (ip) async {
      final String subnet = ip!.substring(0, ip.lastIndexOf('.'));
      const port = 80;
      for (var i = 0; i < 256; i++) {
        String ip = '$subnet.$i';
        await Socket.connect(ip, port,
                timeout: const Duration(milliseconds: 50))
            .then((socket) async {
          await InternetAddress(socket.address.address).reverse().then((value) {
            printMessage(value.host);
            printMessage(socket.address.address);
          }).catchError((error) {
            printErrorMessage(socket.address.address);
            printErrorMessage('Error: $error');
          });
          socket.destroy();
        }).catchError((error) => null);
      }
    },
  );
  printMessage('Done');
}

// Send a test request to udp server
void testUDP() {
  scanNetwork();
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
  printMessage("Send data: $title");

  // Send to udp
  var udpAddress =
      InternetAddress((await NetworkInfo().getWifiIP()).toString());
  RawDatagramSocket.bind(udpAddress, 0).then((RawDatagramSocket socket) {
    printMessage('Sending from ${socket.address.address}:${socket.port}');
    int port = udpPort;
    socket.send('Hello from UDP land!\n'.codeUnits, udpAddress, port);
  });
}
