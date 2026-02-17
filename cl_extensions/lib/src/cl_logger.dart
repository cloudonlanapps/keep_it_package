import 'dart:developer' as dev;

class TColor {
  static const red = '\x1b[31m';
  static const green = '\x1b[32m';
  static const yellow = '\x1b[33m';
  static const blue = '\x1b[34m';
  static const reset = '\x1b[0m';

  static const bold = '\x1b[1m';
  static const underline = '\x1b[4m';
}

mixin CLLogger {
  String get logPrefix;
  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      '${TColor.blue}$message${TColor.reset}',
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: '${TColor.bold}${TColor.blue}$logPrefix${TColor.reset}',
    );
  }
}
