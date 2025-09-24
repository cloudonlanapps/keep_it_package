import 'package:face_it_desktop/modules/server/views/server_manage_view.dart';
import 'package:face_it_desktop/modules/uploader/views/monitor_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../modules/cl_browser_panel/models/cl_browser_panal.dart';
import '../../modules/cl_browser_panel/providers/cl_browser_panal.dart';
import '../../modules/cl_browser_panel/views/cl_browser_panel_view.dart';
import '../../modules/content_manager/views/logs/log_view.dart';
import '../../modules/content_manager/views/main/main_view.dart';
import '../../modules/face_manager/views/saved_items_browser.dart';
import '../../modules/media/views/media_browser.dart';
import '../../modules/uploader/views/monitor_face_recg.dart';

class FaceItDesktopApp extends ConsumerWidget {
  const FaceItDesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadApp(
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Detect Faces')),
        body: ProviderScope(
          overrides: [
            clBrowserPanalProvider.overrideWith(
              (ref) => CLBrowserPanalNotifier(
                CLBrowserPanals(
                  activePanelLabel: 'Images',
                  availablePanels: [
                    CLBrowserPanal(
                      label: 'Images',
                      panelBuilder: (context) => const MediaBrowser(),
                    ),
                    CLBrowserPanal(
                      label: 'Saved Items',
                      panelBuilder: (context) => const SavedItemsBrowser(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: const FaceItDesktop0(),
        ),
      ),
    );
  }
}

class FaceItDesktop0 extends ConsumerWidget {
  const FaceItDesktop0({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Divider(color: ShadTheme.of(context).colorScheme.muted, height: 1),
        const Expanded(
          child: ShadResizablePanelGroup(
            children: [
              ShadResizablePanel(
                id: 'explorer',
                defaultSize: .2,
                minSize: .1,
                maxSize: .2,
                child: CLBrowserPanelView(
                  leading: [ServerManageView(), Monitors()],
                ),
              ),
              ShadResizablePanel(
                id: 'mainPanel',
                defaultSize: .6,
                minSize: .2,
                child: MainPanelView(),
              ),
              ShadResizablePanel(
                id: 'logView',
                defaultSize: .2,
                minSize: .1,
                child: LogView(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Monitors extends StatelessWidget {
  const Monitors({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        children: [
          Expanded(child: MonitorUpload()),
          Expanded(child: MonitorFaceRecg()),
        ],
      ),
    );
  }
}
