import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_size/window_size.dart';

import 'app/views/face_it_desktop.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowFrame(const Rect.fromLTWH(0, 0, 1400, 900));

    //setWindowMaxSize(const Size(1400, 900));
    setWindowMinSize(const Size(1000, 900));
  }
  runApp(const ProviderScope(child: ShadApp(home: FaceItDesktopApp())));
}
