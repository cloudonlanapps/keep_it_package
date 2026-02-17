import 'dart:io';

import 'package:cl_basic_types/cl_basic_types.dart' hide ValueGetter;
import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../models/platform_support.dart';
import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';

@immutable
class EntityActions extends CLContextMenu {
  const EntityActions({
    required this.serverId,
    required this.name,
    required this.logoImageAsset,
    required this.onCrop,
    required this.onEdit,
    required this.onMove,
    required this.onShare,
    required this.onPin,
    required this.onDelete,
    required this.infoMap,
    required this.moveTaskManager,
  });

  factory EntityActions.entities(
    BuildContext context,
    ViewerEntities entities, {
    required String serverId,
    required StoreTaskManager moveTaskManager,
  }) {
    return switch (entities) {
      final ViewerEntities e
          when e.entities.every(
            (e) => e is StoreEntity && !e.isCollection,
          ) =>
        () {
          return EntityActions.ofMultipleMedia(
            context,
            items: e,
            serverId: serverId,
            moveTaskManager: moveTaskManager,
            hasOnlineService: true,
          );
        }(),
      final ViewerEntities e
          when e.entities.every(
            (e) => e is StoreEntity && e.isCollection,
          ) =>
        () {
          return EntityActions.empty(serverId: serverId);
        }(),
      _ => () {
        return EntityActions.empty(serverId: serverId);
      }(),
    };
  }
  factory EntityActions.ofEntity(
    BuildContext context,
    WidgetRef ref,
    StoreEntity entity, {
    required String serverId,
    required StoreTaskManager moveTaskManager,
  }) {
    Future<bool> onEdit() async {
      if (context.mounted) {
        final updated = await (entity.isCollection
            ? CollectionMetadataEditor.openSheet(
                context,
                collection: entity,
                store: entity.store,
                suggestedLabel: null,
                description: null,
              )
            : MediaMetadataEditor.openSheet(
                context,
                ref,
                media: entity,
              ));
        if (updated != null && context.mounted) {
          await updated.dbSave();
          ref.read(reloadProvider.notifier).reload();
        }
      }

      return true;
    }

    final cropSupported = switch (entity.mediaType) {
      CLMediaType.text => false,
      CLMediaType.image => true,
      CLMediaType.video => ColanPlatformSupport.isMobilePlatform,
      CLMediaType.uri => false,
      CLMediaType.audio => false,
      CLMediaType.file => false,
      CLMediaType.unknown => false,
      CLMediaType.collection => false,
    };

    Future<bool> onCrop({required String serverId}) async {
      await PageManager.of(context).openEditor(entity, serverId: serverId);
      return true;
    }

    Future<bool?> onMove({required String serverId}) async {
      moveTaskManager.add(
        StoreTask(
          items: [entity],
          contentOrigin: ContentOrigin.move,
        ),
      );
      await PageManager.of(context).openWizard(ContentOrigin.move);
      return true;
    }

    Future<bool> onDelete() async {
      final confirmed =
          await DialogService.deleteEntity(
            context,
            serverId: serverId,
            entity: entity,
          ) ??
          false;

      if (confirmed && context.mounted) {
        await entity.delete();
        ref.read(reloadProvider.notifier).reload();
        return true;
      }
      return false;
    }

    Future<bool?> onShare() => share(context, ViewerEntities([entity]));

    Future<bool> onPin() async {
      await entity.onPin();
      ref.read(reloadProvider.notifier).reload();
      return true;
    }

    return EntityActions.template(
      serverId: serverId,
      moveTaskManager: moveTaskManager,
      name: entity.label ?? 'Unnamed',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onCrop: cropSupported ? () => onCrop(serverId: serverId) : null,
      onEdit: onEdit,
      onMove: () => onMove(serverId: serverId),
      onShare: entity.isCollection ? null : onShare,
      onPin: !entity.isCollection && !ColanPlatformSupport.isMobilePlatform
          ? onPin
          : null,
      onDelete: onDelete,
      infoMap: entity.toMapForDisplay(),
      isPinned: false,
    );
  }
  factory EntityActions.empty({
    required String serverId,
  }) {
    return EntityActions.template(
      serverId: serverId,
      moveTaskManager: null,
      name: 'No Context Menu',
      logoImageAsset: '',
      infoMap: const {},
      isPinned: false,
    );
  }
  factory EntityActions.template({
    required String serverId,
    required StoreTaskManager? moveTaskManager,
    required String name,
    required String logoImageAsset,
    required Map<String, dynamic> infoMap,
    required bool isPinned,
    Future<bool?> Function()? onCrop,
    Future<bool?> Function()? onEdit,
    Future<bool?> Function()? onMove,
    Future<bool?> Function()? onShare,
    Future<bool?> Function()? onPin,
    Future<bool?> Function()? onDelete,
  }) {
    return EntityActions(
      serverId: serverId,
      name: name,
      logoImageAsset: logoImageAsset,
      onCrop: CLMenuItem(
        title: 'Edit',
        icon: clIcons.imageCrop,
        onTap: onCrop,
      ),
      onEdit: CLMenuItem(
        title: 'Info',
        icon: clIcons.imageEdit,
        onTap: onEdit,
      ),
      onMove: CLMenuItem(
        title: 'Move',
        icon: clIcons.imageMove,
        onTap: onMove,
      ),
      onShare: CLMenuItem(
        title: 'Share',
        icon: clIcons.imageShare,
        onTap: onShare,
      ),
      onPin: CLMenuItem(
        title: isPinned ? 'Remove Pin' : 'Pin',
        icon: isPinned ? clIcons.pin : clIcons.unPin,
        onTap: onPin,
      ),
      onDelete: CLMenuItem(
        title: 'Remove',
        icon: clIcons.imageDelete,
        onTap: onDelete,
        isDestructive: true,
        tooltip: 'Moves to Recycle bin. Can recover as per Recycle Policy',
      ),
      infoMap: infoMap,
      moveTaskManager: moveTaskManager,
    );
  }

  factory EntityActions.ofMultipleMedia(
    BuildContext context, {
    required StoreTaskManager moveTaskManager,
    required String serverId,
    required ViewerEntities items,
    // ignore: avoid_unused_constructor_parameters For now, not required
    required bool hasOnlineService,
    ValueGetter<Future<bool?> Function()?>? onCrop,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
  }) {
    final onEdit0 = onCrop?.call();
    final onEditInfo0 = onEdit?.call();
    Future<bool?> onMove0() async {
      moveTaskManager.add(
        StoreTask(
          items: items.entities.cast<StoreEntity>(),
          contentOrigin: ContentOrigin.move,
        ),
      );
      await PageManager.of(context).openWizard(ContentOrigin.move);
      return true;
    }

    Future<bool?> onShare0() => share(context, items);
    Future<bool> onPin0() async {
      for (final item in items.entities.cast<StoreEntity>()) {
        await item.onPin();
      }
      return true;
    }

    Future<bool> onDelete0() async {
      final confirmed =
          await DialogService.deleteMultipleEntities(
            context,
            serverId: serverId,
            media: items,
          ) ??
          false;
      if (!confirmed) return confirmed;
      if (context.mounted) {
        for (final item in items.entities.cast<StoreEntity>()) {
          await item.delete();
        }
        return true;
      }
      return false;
    }

    return EntityActions.template(
      serverId: serverId,
      moveTaskManager: moveTaskManager,
      name: 'Multiple Media',
      logoImageAsset: 'assets/icon/not_on_server.png',
      onCrop: onCrop != null ? onCrop() : onEdit0,
      onEdit: onEdit != null ? onEdit() : onEditInfo0,
      onMove: onMove != null ? onMove() : onMove0,
      onShare: onShare != null ? onShare() : onShare0,
      onPin: onPin != null ? onPin() : onPin0,
      onDelete: onDelete != null ? onDelete() : onDelete0,
      infoMap: const {},
      isPinned: items.entities.cast<StoreEntity>().any(
        (media) => media.pin != null,
      ),
    );
  }
  final String serverId;
  final StoreTaskManager? moveTaskManager;
  final String name;
  final String logoImageAsset;
  final CLMenuItem onCrop;
  final CLMenuItem onEdit;
  final CLMenuItem onMove;
  final CLMenuItem onShare;
  final CLMenuItem onPin;
  final CLMenuItem onDelete;

  final Map<String, dynamic> infoMap;

  @override
  List<CLMenuItem> get actions => [
    onCrop,
    onEdit,
    onMove,
    onShare,
    onPin,
    onDelete,
  ].where((e) => e.onTap != null).toList();

  List<CLMenuItem> get basicActions => [
    onCrop,
    onEdit,
    onMove,
    onShare,
    onPin,
  ];

  List<CLMenuItem> get destructiveActions => [
    onDelete,
  ];

  static Future<bool?> share(
    BuildContext context,
    ViewerEntities media,
  ) {
    final files = media.entities
        .where((e) => e.mediaUri != null)
        .map((e) => e.mediaUri!.toFilePath())
        .where((e) => File(e).existsSync());

    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      files.toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}

typedef DraggableMenuBuilderType =
    Widget Function(
      BuildContext, {
      required GlobalKey<State<StatefulWidget>> parentKey,
    });
