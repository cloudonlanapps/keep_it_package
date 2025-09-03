import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/store.dart';

class ContentSourceSelectorIcon extends ConsumerStatefulWidget {
  const ContentSourceSelectorIcon({super.key});

  @override
  ConsumerState<ContentSourceSelectorIcon> createState() =>
      ContentSourceSelectorIconState();
}

class ContentSourceSelectorIconState
    extends ConsumerState<ContentSourceSelectorIcon> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
        controller: popoverController,
        popover: (context) =>
            const SizedBox(width: 288, child: ShowAvailableServers()),
        child: ShadButton.ghost(
          onPressed: popoverController.toggle,
          child: clIcons.connectToServer.iconFormatted(),
        ));
  }
}

class ShowAvailableServers extends ConsumerWidget {
  const ShowAvailableServers({super.key, this.supportedSchema = const []});
  final List<String> supportedSchema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadingWidget = Center(child: CircularProgressIndicator.adaptive());
    const errorWidget = Center(
      child: Icon(LucideIcons.triangleAlert),
    );
    return GetRegisterredURLs(
        loadingBuilder: () => loadingWidget,
        errorBuilder: (p0, p1) => errorWidget,
        builder: (availableStores) {
          return KnownServersList(
            servers: availableStores,
            supportedSchema: supportedSchema,
          );
        });
  }
}

class KnownServersList extends ConsumerWidget {
  const KnownServersList({
    required this.servers,
    required this.supportedSchema,
    super.key,
  });
  final RegisteredURLs servers;
  final List<String> supportedSchema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CLUrl> stores;
    if (supportedSchema.isNotEmpty) {
      stores = servers.availableStores
          .where((e) => supportedSchema.contains(e.scheme))
          .toList();
    } else {
      stores = servers.availableStores;
    }
    return ListView(
      shrinkWrap: true,
      children: stores
          .map((storeURL) => GetStore(
              storeURL: storeURL,
              errorBuilder: (p0, p1) => ServerTile(
                    storeURL: storeURL,
                    isLoading: false,
                    isActive: servers.isActiveStore(storeURL),
                  ),
              loadingBuilder: () => ServerTile(
                    storeURL: storeURL,
                    isLoading: true,
                    isActive: servers.isActiveStore(storeURL),
                  ),
              builder: (store) => ServerTile(
                    storeURL: storeURL,
                    store: store,
                    isLoading: false,
                    isActive: servers.isActiveStore(storeURL),
                  )))
          .toList(),
    );
  }
}

class ServerTile extends ConsumerWidget {
  const ServerTile(
      {required this.storeURL,
      required this.isLoading,
      required this.isActive,
      super.key,
      this.store});
  final CLUrl storeURL;
  final CLStore? store;
  final bool isLoading;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IconData icon;
    final Color? color;
    if (isLoading) {
      icon = LucideIcons.circle;
      color = null;
    } else if (isLoading || (store?.store.isAlive ?? false)) {
      icon = (isActive ? LucideIcons.circleCheck : LucideIcons.circle);
      color = null;
    } else {
      icon = clIcons.noNetwork;
      color = Colors.red;
    }

    final child = ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        enabled: store?.store.isAlive ?? false,
        title: Text(
          storeURL.label ?? storeURL.name,
          style: ShadTheme.of(context).textTheme.small,
        ),
        onTap: (!isLoading && store != null)
            ? () =>
                ref.read(registeredURLsProvider.notifier).activeStore = storeURL
            : null);

    if (isLoading) {
      return Shimmer.fromColors(
          baseColor: Colors.grey[500]!,
          highlightColor: Colors.grey[800]!,
          child: child);
    }
    return child;
  }
}
