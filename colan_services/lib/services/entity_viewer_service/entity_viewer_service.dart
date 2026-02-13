import 'package:colan_services/services/entity_viewer_service/views/keep_it_error_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/keep_it_grid_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/keep_it_load_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/keep_it_page_view.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basic_page_service/widgets/page_manager.dart';

class EntityViewerService extends ConsumerWidget {
  const EntityViewerService({
    required this.serverId,
    required this.id,
    super.key,
  });
  final String serverId;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    KeepItLoadView loadBuilder() => const KeepItLoadView();

    return GetRegisteredServiceLocations(
        loadingBuilder: loadBuilder,
        errorBuilder: (e, st) => KeepItErrorView(e: e, st: st),
        builder: (registeredURLs) {
          if (id != null) {
            try {
              if (registeredURLs.activeConfig.displayName != serverId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  PageManager.of(context).home();
                });
                throw Exception(
                    "This page doesn't exists. Refresh. or Wait for Auto redirect");
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
        });
  }
}
