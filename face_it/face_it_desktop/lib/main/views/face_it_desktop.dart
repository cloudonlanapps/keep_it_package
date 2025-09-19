import 'package:face_it_desktop/modules/server/views/server_manage_view.dart';
import 'package:face_it_desktop/modules/uploader/views/upload_monitor.dart';
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

class FaceItDesktop extends ConsumerWidget {
  const FaceItDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ShadTheme.of(context);
    return Scaffold(
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
                  leading: [ServerManageView(), UploadMonitor()],
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
