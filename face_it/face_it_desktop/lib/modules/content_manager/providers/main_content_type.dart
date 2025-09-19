import 'package:face_it_desktop/main/providers/main_content_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeMainContentTypeProvider = StateProvider<MainContentType>((ref) {
  return MainContentType.images;
});
