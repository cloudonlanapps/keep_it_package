/// Camera Service - Camera capture and media management.
library;

// Export builders
export 'builders/get_cameras.dart';
export 'builders/get_captured_media.dart'
    show CapturedMediaActions, GetCapturedMedia;

// Export models
export 'models/default_theme.dart' show DefaultCLCameraIcons;

// Export providers (for services needing direct access)
export 'providers/cameras_provider.dart' show camerasProvider;
export 'providers/captured_media_provider.dart' show capturedMediaProvider;
