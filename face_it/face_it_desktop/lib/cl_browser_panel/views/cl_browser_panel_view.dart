// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/cl_browser_panal.dart';
import '../providers/cl_browser_panal.dart';

class CLBrowserPanelView extends ConsumerStatefulWidget {
  const CLBrowserPanelView({super.key});

  @override
  ConsumerState<CLBrowserPanelView> createState() => _CLBrowserPanelViewState();
}

class _CLBrowserPanelViewState extends ConsumerState<CLBrowserPanelView> {
  late final ScrollController scrollController;
  late List<CLBrowserPanal> panels;
  @override
  void initState() {
    scrollController = ScrollController();
    panels = ref.read(clBrowserPanalProvider.select((v) => v.activePanels));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(clBrowserPanalProvider, (prev, curr) {
      setState(() {
        panels = curr.activePanels;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          //  scrollController.jumpTo(0);
        });
      });
    });
    return Column(
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
            Expanded(child: panels[index].panelBuilder(context)),
        ],
      ],
    );
    /* 
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        controller: scrollController,
        child: ExpansionPanelList(
          expansionCallback: (index, isExpanded) {
            ref
                .read(clBrowserPanalProvider.notifier)
                .onTogglePanelByLabel(panels[index].label);
          },
          children: [
            for (int index = 0; index < panels.length; index++)
              ExpansionPanel(
                canTapOnHeader: true,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(title: Text(panels[index].label));
                },
                body: panels[index].panelBuilder(context),
                isExpanded: panels[index].isExpanded,
              ),
          ],
        ),
      ),
    ); */
  }
}
