import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:face_it_desktop/modules/server/providers/upload_url_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../uploader/providers/uploader.dart';

class AutoRetryUpload with CLLogger {
  // Call this function only inside a build
  void watch(WidgetRef ref) {
    ref.listen(uploadURLProvider, (prev, curr) {
      if (prev == null && curr != null) {
        ref.read(uploaderProvider.notifier).retryNew(curr);
      } else if (prev != null && curr == null) {
        ref.read(uploaderProvider.notifier).resetNew();
      }
    });
  }

  @override
  String get logPrefix => 'AutoRetryUpload';
}
