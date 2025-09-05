import 'dart:developer' as dev;

mixin CLLogger {
  String get logPrefix;
  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: logPrefix,
    );
  }
}
