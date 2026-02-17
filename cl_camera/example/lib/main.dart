import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'screens/camera_screen.dart';
import 'screens/captured_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CLCameraExampleApp());
}

class CLCameraExampleApp extends StatelessWidget {
  const CLCameraExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'cl_camera Example',
      darkTheme: ShadThemeData(
        colorScheme: const ShadSlateColorScheme.dark(),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<void>(
              builder: (_) => const CameraScreen(),
            );
          case '/captured':
            final paths = settings.arguments as List<String>;
            return MaterialPageRoute<void>(
              builder: (_) => CapturedListScreen(paths: paths),
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const CameraScreen(),
            );
        }
      },
    );
  }
}
