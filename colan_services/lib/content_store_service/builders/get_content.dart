import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetContent extends ConsumerWidget {
  const GetContent({
    required this.id,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final int? id;
  final Widget Function(
    StoreEntity? entity,
    ViewerEntities children,
    ViewerEntities siblings, {
    Future<void> Function()? onLoadMoreChildren,
    Future<void> Function()? onLoadMoreSiblings,
  })
  builder;
  final CLLoadingView Function() loadingBuilder;
  final CLErrorView Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetEntity(
      id: id,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (entity) {
        return GetEntities(
          parentId: id,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (children, {onLoadMore}) {
            final onLoadMoreChildren = onLoadMore;
            if (entity == null) {
              return builder(
                entity,
                children,
                const ViewerEntities([]),
                onLoadMoreChildren: onLoadMoreChildren,
              );
            }
            return GetEntities(
              parentId: entity.parentId,
              errorBuilder: errorBuilder,
              loadingBuilder: loadingBuilder,
              builder: (siblings, {onLoadMore}) {
                return builder(
                  entity,
                  children,
                  siblings,
                  onLoadMoreChildren: onLoadMoreChildren,
                  onLoadMoreSiblings: onLoadMore, // on siblings
                );
              },
            );
          },
        );
      },
    );
  }
}
