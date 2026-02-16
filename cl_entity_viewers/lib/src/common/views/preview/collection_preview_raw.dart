import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../page_view/views/media_preview.dart';

import 'collection_folder_item.dart';

//
class EntityViewRaw extends StatelessWidget {
  const EntityViewRaw({
    super.key,
    required this.entity,
    this.grayFilter = false,
  });
  final ViewerEntity entity;
  final bool grayFilter;

  @override
  Widget build(BuildContext context) {
    final Widget widget;
    if (entity.isCollection) {
      widget = LayoutBuilder(
        builder: (context, constrain) {
          return Stack(
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
          );
        },
      );
    } else {
      widget = MediaThumbnail(media: entity);
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
    if (!entity.isCollection || children.isEmpty) {
      return EntityViewRaw(
        entity: entity,
        grayFilter: isFilterredOut?.call(entity) ?? false,
      );
    }
    return FolderItem(
      name: entity.label!,
      borderColor: borderColor,
      // avatarAsset: 'assets/icon/not_on_server.png',
      counter: counter,
      child: CLMediaCollage.byMatrixSize(
        children.length,
        hCount: 3,
        vCount: 3,
        itemBuilder: (context, index) {
          return EntityViewRaw(
            entity: children.entities[index],
            grayFilter: isFilterredOut?.call(children.entities[index]) ?? false,
          );
        },
      ),
    );
  }
}
