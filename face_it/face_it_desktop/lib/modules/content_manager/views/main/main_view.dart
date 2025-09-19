import 'package:face_it_desktop/main/providers/main_content_type.dart';
import 'package:face_it_desktop/modules/content_manager/views/main/faces_view.dart';
import 'package:face_it_desktop/modules/content_manager/views/main/persons_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/main_content_type.dart';
import 'content_viewer.dart';

class MainPanelView extends ConsumerWidget {
  const MainPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMainContentType = ref.watch(activeMainContentTypeProvider);
    return switch (activeMainContentType) {
      MainContentType.images => const ContentViewer(),
      MainContentType.faces => const FacesView(),
      MainContentType.persons => const PersonsView(),
    };
  }
}
