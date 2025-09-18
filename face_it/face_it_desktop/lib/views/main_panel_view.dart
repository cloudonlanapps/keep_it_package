import 'package:face_it_desktop/models/main_content_type.dart';
import 'package:face_it_desktop/providers/main_content_type.dart';
import 'package:face_it_desktop/views/faces/faces_view.dart';
import 'package:face_it_desktop/views/image/active_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPanelView extends ConsumerWidget {
  const MainPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMainContentType = ref.watch(activeMainContentTypeProvider);
    return switch (activeMainContentType) {
      MainContentType.images => const ActiveImage(),
      MainContentType.faces => const FacesView(),
      MainContentType.persons => const PersonsView(),
    };
  }
}

class PersonsView extends ConsumerWidget {
  const PersonsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Known Persons'));
  }
}
