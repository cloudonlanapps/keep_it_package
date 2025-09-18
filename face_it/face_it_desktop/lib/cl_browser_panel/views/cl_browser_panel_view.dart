import 'package:face_it_desktop/cl_browser_panel/views/cl_browser_container.dart';
import 'package:face_it_desktop/cl_browser_panel/views/cl_browser_place_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/cl_browser_panal.dart';

class CLBrowserPanelView extends ConsumerStatefulWidget {
  const CLBrowserPanelView({super.key});

  @override
  ConsumerState<CLBrowserPanelView> createState() => _CLBrowserPanelViewState();
}

class _CLBrowserPanelViewState extends ConsumerState<CLBrowserPanelView> {
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panels = ref.watch(
      clBrowserPanalProvider.select((e) => e.activePanels),
    );
    return Column(
      children: [
        // FIXME: Server selector here
        Expanded(
          child: Column(
            children: [
              for (int index = 0; index < panels.length; index++) ...[
                GestureDetector(
                  onTap: () => ref
                      .read(clBrowserPanalProvider.notifier)
                      .onTogglePanelByLabel(panels[index].label),
                  child: ListTile(
                    title: Text(panels[index].label),
                    trailing: Icon(
                      panels[index].isExpanded
                          ? LucideIcons.chevronDown200
                          : LucideIcons.chevronRight200,
                    ),
                  ),
                ),
                if (panels[index].isExpanded)
                  Expanded(
                    child: CLBrowserContainer(
                      child:
                          panels[index].panelBuilder?.call(context) ??
                          const CLBrowserPlaceHolder(),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
