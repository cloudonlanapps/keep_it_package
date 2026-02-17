import 'package:colan_services/colan_services.dart';
import 'package:colan_services/views/entity_viewer_views/keep_it_error_view.dart';
import 'package:colan_services/views/entity_viewer_views/keep_it_grid_view.dart';
import 'package:colan_services/views/entity_viewer_views/keep_it_load_view.dart';
import 'package:colan_services/views/entity_viewer_views/keep_it_page_view.dart';
import 'package:flutter/material.dart';

import '../page_manager.dart';

class EntityViewerService extends StatelessWidget {
  const EntityViewerService({
    required this.serverId,
    required this.id,
    super.key,
  });
  final String serverId;
  final int? id;

  @override
  Widget build(BuildContext context) {
    KeepItLoadView loadBuilder() => const KeepItLoadView();

    return GetRegisteredServiceLocations(
      loadingBuilder: loadBuilder,
      errorBuilder: (e, st) => KeepItErrorView(e: e, st: st),
      builder: (registeredURLs, _) {
        if (id != null) {
          try {
            if (registeredURLs.activeConfig.displayName != serverId) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                PageManager.of(context).home();
              });
              throw Exception(
                "This page doesn't exists. Refresh. or Wait for Auto redirect",
              );
            }
          } catch (e, st) {
            return KeepItErrorView(e: e, st: st);
          }
        }
        return GetContent(
          id: id,
          loadingBuilder: loadBuilder,
          errorBuilder: (e, st) => KeepItErrorView(e: e, st: st),
          builder: (entity, children, siblings) {
            if (entity?.isCollection ?? true) {
              return KeepItGridView(
                serverId: registeredURLs.activeConfig.displayName,
                parent: entity,
                children: children,
              );
            } else {
              return KeepItPageView(
                serverId: registeredURLs.activeConfig.displayName,
                entity: entity!,
                siblings: siblings,
              );
            }
          },
        );
      },
    );
  }
}
