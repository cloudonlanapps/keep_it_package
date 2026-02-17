import 'package:colan_services/with_provider_context.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../init_service/builders/get_app_init_status.dart';
import '../../init_service/models/app_descriptor.dart';
import '../../preference_service/builders/get_theme_mode.dart';
import '../../views/incoming_media_views/incoming_media_monitor.dart';

class AppStartView extends StatelessWidget {
  const AppStartView({required this.appDescriptor, super.key});
  final AppDescriptor appDescriptor;
  @override
  Widget build(BuildContext context) {
    final app = appDescriptor;
    return WithProviderContext(
      child: GetThemeMode(
        builder: (themeMode, actions) => ShadApp(
          title: app.title,
          initialRoute: '/',
          home: CLTheme(
            colors: const DefaultCLColors(),
            // noteTheme: const DefaultNotesTheme(),
            child: GetAppInitStatus(
              app: app,
              builder: () {
                final screen = app.screens
                    .where(
                      (s) => s.name == '',
                    )
                    .firstOrNull;
                if (screen == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('404: Page not found'),
                    ),
                  );
                }
                return IncomingMediaMonitor(
                  child: screen.builder(context, {}),
                );
              },
            ),
          ),
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadZincColorScheme.light(),
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadZincColorScheme.dark(),
          ),
          themeMode: themeMode,
          onGenerateRoute: (settings) {
            final uri = Uri.parse(settings.name ?? '');

            return PageRouteBuilder(
              transitionsBuilder: app.transitionBuilder,
              pageBuilder: (context, animation, secondaryAnimation) => CLTheme(
                colors: const DefaultCLColors(),
                // noteTheme: const DefaultNotesTheme(),
                child: GetAppInitStatus(
                  app: app,
                  builder: () {
                    final screen = app.screens
                        .where(
                          (s) => s.name == uri.path.replaceFirst('/', ''),
                        )
                        .firstOrNull;
                    if (screen == null) {
                      return const Scaffold(
                        body: Center(
                          child: Text('404: Page not found'),
                        ),
                      );
                    }
                    return IncomingMediaMonitor(
                      child: screen.builder(context, uri.queryParameters),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
