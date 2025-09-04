import 'package:face_it_desktop/cl_browser_panel/views/cl_browser_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLBrowserPlaceHolder extends ConsumerWidget {
  const CLBrowserPlaceHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CLBrowserContainer();
  }
}
