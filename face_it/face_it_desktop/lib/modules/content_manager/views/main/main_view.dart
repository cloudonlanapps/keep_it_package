import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main/models/main_content_type.dart';
import '../../../face_manager/views/faces_view.dart';
import '../../../media/views/media_view.dart';
import '../../../../main/providers/main_content_type.dart';
import '../../../face_manager/views/persons_view.dart';

class MainPanelView extends ConsumerWidget {
  const MainPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMainContentType = ref.watch(activeMainContentTypeProvider);
    return switch (activeMainContentType) {
      MainContentType.images => const MediaViewer(),
      MainContentType.faces => const FacesView(),
      MainContentType.persons => const PersonsView(),
    };
  }
}
