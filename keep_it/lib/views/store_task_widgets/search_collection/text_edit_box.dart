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
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Expanded(
          flex: 13,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: collection == null
                  ? InputDecoration(
                      hintStyle: ShadTheme.of(context).textTheme.muted,
                      hintText: hintText)
                  : null,
              readOnly: onTap != null,
              showCursor: onTap == null,
              enableInteractiveSelection: false,
              onTap: onTap,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Align(alignment: Alignment.centerRight, child: serverWidget),
        )
      ],
    );
  }
}
