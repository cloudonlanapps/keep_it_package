import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart';
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
  runApp(
    ProviderScope(
      observers: [MyProviderObserver()],
      child: const FaceItDesktopApp(),
    ),
  );
}

class MyProviderObserver extends ProviderObserver with CLLogger {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    log('Provider added: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    log('Provider disposed: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    log('Provider updated: ${provider.name ?? provider.runtimeType}');
  }

  @override
  // TODO: implement logPrefix
  String get logPrefix => 'MyProviderObserver';
}
