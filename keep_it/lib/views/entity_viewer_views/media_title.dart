import 'package:cl_extensions/cl_extensions.dart' show UtilExtensionOnString;
import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class MediaTitle extends StatelessWidget {
  const MediaTitle({
    required this.entity,
    super.key,
  });
  final StoreEntity? entity;

  @override
  Widget build(BuildContext context) {
    return GetActiveStore(
      loadingBuilder: () => const CustomListTile(title: 'Keep It'),
      errorBuilder: (e, st) => const CustomListTile(title: 'Keep It'),
      builder: (activeStore) {
        const defaultTitle = CustomListTile(
          title: 'Keep It',
        );
        return Column(
          children: [
            if (entity == null)
              defaultTitle
            else
              CustomListTile(
                title:
                    entity!.label?.capitalizeFirstLetter() ??
                    'media #${entity!.id ?? "New Media"}',
                subTitle: entity!.dateString,
              ),
          ],
        );
      },
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({required this.title, super.key, this.subTitle});
  final String title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: ShadTheme.of(context).textTheme.h3,
        ),
        if (subTitle != null)
          Text(
            subTitle!,
            style: ShadTheme.of(context).textTheme.small,
          ),
      ],
    );
  }
}
