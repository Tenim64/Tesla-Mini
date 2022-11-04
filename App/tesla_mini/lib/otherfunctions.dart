// Packages
import 'package:flutter/foundation.dart';
import 'package:restart_app/restart_app.dart';

void restart() {
  debugPrint('Restarting'); // Print in debug console
  Restart.restartApp();
}
