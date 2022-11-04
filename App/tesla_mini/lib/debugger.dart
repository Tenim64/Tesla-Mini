// ignore_for_file: avoid_print

void printErrorMessage(text) {
  print('\x1B[31m$text\x1B[0m');
}

void printTitle(text) {
  print(
      '\x1B[33m-------------------------------- $text --------------------------------\x1B[0m');
}

void printMessage(text) {
  print('\x1B[33m$text\x1B[0m');
}
