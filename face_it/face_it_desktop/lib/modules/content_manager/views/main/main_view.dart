import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/models/main_content_type.dart';
import '../../../../app/providers/main_content_type.dart';

import '../../../media/views/media_view.dart';

class MainPanelView extends ConsumerWidget {
  const MainPanelView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMainContentType = ref.watch(activeMainContentTypeProvider);
    return switch (activeMainContentType) {
      MainContentType.images => const MediaViewer(),
    };
  }
}
