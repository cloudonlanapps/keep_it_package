import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:cl_servers/cl_servers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
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
      ),
    );
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
    return GetRegisteredServiceLocations(
      loadingBuilder: () => loadingWidget,
      errorBuilder: (p0, p1) => errorWidget,
      builder: (availableStores) {
        return KnownServersList(
          servers: availableStores,
          supportedSchema: supportedSchema,
        );
      },
    );
  }
}

class KnownServersList extends ConsumerWidget {
  const KnownServersList({
    required this.servers,
    required this.supportedSchema,
    super.key,
  });
  final RegisteredServiceLocations servers;
  final List<String> supportedSchema;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ServiceLocationConfig> configs;
    if (supportedSchema.isNotEmpty) {
      // Filter by scheme - local configs have 'local' scheme, remote have http/https
      configs = servers.availableConfigs.where((config) {
        if (config is LocalServiceLocationConfig) {
          return supportedSchema.contains('local');
        } else if (config is RemoteServiceLocationConfig) {
          return supportedSchema.contains(config.scheme);
        }
        return false;
      }).toList();
    } else {
      configs = servers.availableConfigs;
    }
    return ListView(
      shrinkWrap: true,
      children: configs
          .map(
            (config) => GetStore(
              storeURL: config,
              errorBuilder: (p0, p1) => ServerTile(
                config: config,
                isLoading: false,
                isActive: servers.isActiveConfig(config),
              ),
              loadingBuilder: () => ServerTile(
                config: config,
                isLoading: true,
                isActive: servers.isActiveConfig(config),
              ),
              builder: (store) => ServerTile(
                config: config,
                store: store,
                isLoading: false,
                isActive: servers.isActiveConfig(config),
              ),
            ),
          )
          .toList(),
    );
  }
}

class ServerTile extends ConsumerWidget {
  const ServerTile({
    required this.config,
    required this.isLoading,
    required this.isActive,
    super.key,
    this.store,
  });

  final ServiceLocationConfig config;
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
    } else if (isLoading || (store?.entityStore.isAlive ?? false)) {
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
      enabled: store?.entityStore.isAlive ?? false,
      title: Text(
        config.label ?? config.displayName,
        style: ShadTheme.of(context).textTheme.small,
      ),
      onTap: (!isLoading && store != null)
          ? () =>
                ref
                        .read(registeredServiceLocationsProvider.notifier)
                        .activeConfig =
                    config
          : null,
    );

    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[500]!,
        highlightColor: Colors.grey[800]!,
        child: child,
      );
    }
    return child;
  }
}
