// Packages
import 'package:restart_app/restart_app.dart';
import 'package:tesla_mini/debugger.dart';

void restart() {
  printMessage('Restarting'); // Print in debug console
  Restart.restartApp();
}
