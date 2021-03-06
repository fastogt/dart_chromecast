import 'dart:developer';

class Logger {
  final String name;

  const Logger(this.name);

  void fine(String message) {
    log(message, name: name, level: 500);
  }

  void info(String message) {
    log(message, name: name, level: 800);
  }

  void severe(String message) {
    log(message, name: name, level: 1000);
  }
}
