import 'package:face_it_desktop/modules/faces/views/person_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/media/views/media_view.dart';
import '../models/main_content_type.dart';
import '../providers/main_content_type.dart';

class MainPanelView extends ConsumerWidget {
  const MainPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMainContentType = ref.watch(activeMainContentTypeProvider);
    return switch (activeMainContentType) {
      MainContentType.images => const MediaViewer(),
      MainContentType.person => const PersonViewer(),
    };
  }
}
