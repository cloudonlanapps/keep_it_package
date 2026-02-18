import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class TextEditBox extends StatelessWidget {
  const TextEditBox({
    required this.controller,
    required this.onTap,
    required this.serverWidget,
    required this.hintText,
    super.key,
    this.collection,
    this.focusNode,
  });
  final StoreEntity? collection;
  final FocusNode? focusNode;

  final TextEditingController controller;
  final void Function()? onTap;
  final Widget? serverWidget;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintStyle: ShadTheme.of(context).textTheme.muted,
              hintText: collection == null ? hintText : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            readOnly: onTap != null,
            showCursor: onTap == null,
            enableInteractiveSelection: false,
            onTap: onTap,
          ),
        ),
        if (serverWidget != null) ...[
          const SizedBox(width: 8),
          serverWidget!,
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}
