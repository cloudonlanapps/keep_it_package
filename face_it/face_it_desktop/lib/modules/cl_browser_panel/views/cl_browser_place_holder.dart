import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cl_browser_container.dart';

class CLBrowserPlaceHolder extends ConsumerWidget {
  const CLBrowserPlaceHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CLBrowserContainer();
  }
}
