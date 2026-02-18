import 'package:cl_basic_types/viewer_types.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../page_view/views/media_preview.dart';

import 'collection_folder_item.dart';

//
class EntityViewRaw extends StatelessWidget {
  const EntityViewRaw({
    super.key,
    required this.entity,
    this.grayFilter = false,
    this.borderRadius = 12,
  });
  final ViewerEntity entity;
  final bool grayFilter;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget widget;
    if (entity.isCollection) {
      widget = LayoutBuilder(
        builder: (context, constrain) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                Image.asset(
                  'assets/icon/icon.png',
                  width: constrain.maxWidth,
                  height: constrain.maxHeight,
                ),
                Text(
                  entity.label!.characters.first,
                  style: ShadTheme.of(context).textTheme.h2,
                ),
              ],
            ),
          );
        },
      );
    } else {
      widget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: MediaThumbnail(media: entity, borderRadius: borderRadius),
      );
    }

    if (grayFilter) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: widget,
      );
    }
    return widget;
  }
}

class CLEntityView extends StatelessWidget {
  const CLEntityView({
    required this.entity,
    this.children = const ViewerEntities([]),
    super.key,
    this.counter,
    this.isFilterredOut,
  });
  final ViewerEntity entity;
  final ViewerEntities children;
  final Widget? counter;
  final bool Function(ViewerEntity entity)? isFilterredOut;

  @override
  Widget build(BuildContext context) {
    final borderColor = ShadTheme.of(context).colorScheme.foreground;

    // For Empty Collections or just the Collection Entity itself (if not acting as a container view?)
    // Actually, if children is empty, we still want to show the Folder Shape to be consistent
    // with the user request "Retain Folder Shape".
    // Previous code returned EntityViewRaw which was just a Card.
    if (!entity.isCollection) {
      return EntityViewRaw(
        entity: entity,
        grayFilter: isFilterredOut?.call(entity) ?? false,
      );
    }

    if (children.isEmpty) {
      return FolderItem(
        name: entity.label!,
        borderColor: borderColor,
        counter: counter,
        child: Image.asset('assets/icon/icon.png', fit: BoxFit.cover),
      );
    }

    // Smart Grid Logic
    // We want a 2x2 Grid.
    // Index 0: Top Left
    // Index 1: Top Right
    // Index 2: Bottom Left
    // Index 3: Bottom Right (If <= 4 items, just Item 3. If > 4 items, Inner 2x2 Grid)

    return FolderItem(
      name: entity.label!,
      borderColor: borderColor,
      counter: counter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildItem(context, 0)),
                const SizedBox(width: 2),
                Expanded(child: _buildItem(context, 1)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildItem(context, 2)),
                const SizedBox(width: 2),
                Expanded(child: _buildQuadrant4(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index >= children.length) {
      return const ColoredBox(color: Colors.transparent); // Empty slot
    }
    final item = children.entities[index];
    return EntityViewRaw(
      entity: item,
      grayFilter: isFilterredOut?.call(item) ?? false,
      borderRadius: 0,
    );
  }

  Widget _buildQuadrant4(BuildContext context) {
    if (children.length <= 3) {
      return const ColoredBox(color: Colors.transparent);
    }
    if (children.length == 4) {
      return _buildItem(context, 3);
    }
    // More than 4 items: Inner 2x2 Grid for items 3, 4, 5, 6
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildItem(context, 3)),
              const SizedBox(width: 2),
              Expanded(child: _buildItem(context, 4)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildItem(context, 5)),
              const SizedBox(width: 2),
              Expanded(child: _buildItem(context, 6)),
            ],
          ),
        ),
      ],
    );
  }
}
