import 'package:cl_server_dart_client/cl_server_dart_client.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:local_store/local_store.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/store.dart';

// Main widget (simple, just handles popover)
class ContentSourceSelector extends StatefulWidget {
  const ContentSourceSelector({super.key});

  @override
  State<ContentSourceSelector> createState() => _ContentSourceSelectorState();
}

class _ContentSourceSelectorState extends State<ContentSourceSelector> {
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
          const SizedBox(width: 288, child: ServerListPopover()),
      child: ShadButton.ghost(
        onPressed: popoverController.toggle,
        child: clIcons.connectToServer.iconFormatted(),
      ),
    );
  }
}

// Flattened popover content (merges ShowAvailableServers + KnownServersList)
class ServerListPopover extends StatelessWidget {
  const ServerListPopover({super.key, this.supportedSchema = const []});

  final List<String> supportedSchema;

  @override
  Widget build(BuildContext context) {
    return GetRegisteredServiceLocations(
      loadingBuilder: () =>
          const Center(child: CircularProgressIndicator.adaptive()),
      errorBuilder: (e, st) =>
          const Center(child: Icon(LucideIcons.triangleAlert)),
      builder: (locations, actions) {
        // Actions available in closure!
        // Filter logic (was in KnownServersList)
        final configs = locations.availableConfigs.where((config) {
          if (supportedSchema.isEmpty) return true;
          // Filter by scheme
          if (config is LocalServiceLocationConfig) {
            return supportedSchema.contains('local');
          } else if (config is RemoteServiceLocationConfig) {
            return supportedSchema.contains(config.scheme);
          }
          return false;
        }).toList();

        return ListView(
          shrinkWrap: true,
          children: configs.map((config) {
            return GetStore(
              storeURL: config,
              builder: (store) => ServerTile(
                config: config,
                store: store,
                isActive: locations.isActiveConfig(config),
                actions: actions, // Direct access from closure!
              ),
              loadingBuilder: () => ServerTile(
                config: config,
                isLoading: true,
                isActive: locations.isActiveConfig(config),
                actions: actions,
              ),
              errorBuilder: (e, st) => ServerTile(
                config: config,
                isActive: locations.isActiveConfig(config),
                actions: actions,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ServerTile (simple, uses actions)
class ServerTile extends StatelessWidget {
  const ServerTile({
    required this.config,
    required this.isActive,
    required this.actions,
    super.key,
    this.store,
    this.isLoading = false,
  });

  final ServiceLocationConfig config;
  final CLStore? store;
  final bool isLoading;
  final bool isActive;
  final RegisteredServiceLocationsActions actions;

  @override
  Widget build(BuildContext context) {
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
                actions.setActiveConfig(config) // Use action
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
