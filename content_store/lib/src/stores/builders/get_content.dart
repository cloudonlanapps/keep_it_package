import 'package:cl_basic_types/cl_basic_types.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetContent extends ConsumerWidget {
  const GetContent(
      {required this.id,
      required this.builder,
      required this.errorBuilder,
      required this.loadingBuilder,
      super.key});
  final int? id;
  final Widget Function(
          StoreEntity? entity, ViewerEntities children, ViewerEntities siblings)
      builder;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

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
          builder: (children) {
            if (entity == null) {
              return builder(entity, children, const ViewerEntities([]));
            }
            return GetEntities(
                parentId: entity.parentId,
                errorBuilder: errorBuilder,
                loadingBuilder: loadingBuilder,
                builder: (siblings) {
                  return builder(entity, children, siblings);
                });
          },
        );
      },
    );
  }
}
