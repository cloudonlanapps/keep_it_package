import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ColanPlatformSupport {
  static bool get cameraSupported => isMobilePlatform;
  static bool get cameraUnsupported => !cameraSupported;

  static bool get incomingMediaSupported => isMobilePlatform;
  static bool get incomingMediaUnsupported => !cameraSupported;

  static bool get isMobilePlatform =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);
}
