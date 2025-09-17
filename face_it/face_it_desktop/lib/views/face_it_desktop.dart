import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../cl_browser_panel/models/cl_browser_panal.dart';
import '../cl_browser_panel/providers/cl_browser_panal.dart';
import '../cl_browser_panel/views/cl_browser_panel_view.dart';
import 'browser/image_browser.dart';
import 'browser/saved_items_browser.dart';
import 'logs/log_view.dart';
import 'main_panel_view.dart';

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
                    panelBuilder: (context) => const ImageBrowser(),
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
                child: CLBrowserPanelView(),
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
