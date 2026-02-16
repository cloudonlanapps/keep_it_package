import 'package:flutter/material.dart';

import 'store_selector.dart';
import 'text_edit_box.dart';

class EntitySearchBar extends StatelessWidget implements PreferredSizeWidget {
  const EntitySearchBar({
    required this.controller,
    required this.onClose,
    required this.focusNode,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kMinInteractiveDimension * 3,
      child: Hero(
        tag: 'Search bar',
        child: TextEditBox(
          controller: controller,
          focusNode: focusNode,
          onTap: null,
          serverWidget: StoreSelector(onClose: onClose),
          hintText: 'Search here',
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size(double.infinity, kMinInteractiveDimension * 3);
}
