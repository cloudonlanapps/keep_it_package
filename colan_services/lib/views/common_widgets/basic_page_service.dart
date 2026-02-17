import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../page_manager.dart';

class BasicPageService extends StatelessWidget {
  const BasicPageService._({
    required this.message,
    required this.menuItems,
    super.key,
  });
  // Use with Page
  factory BasicPageService.withNavBar({
    required dynamic message,
    List<CLMenuItem>? menuItems,
  }) {
    return BasicPageService._(
      message: message,
      menuItems: menuItems,
      key: ValueKey('$message ${true}'),
    );
  }
  // Use as Widget
  factory BasicPageService.message({
    required dynamic message,
  }) {
    return BasicPageService._(
      message: message,
      menuItems: const [],
      key: ValueKey('$message ${false}'),
    );
  }

  final dynamic message;

  final List<CLMenuItem>? menuItems;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          Expanded(
            child: (message is String)
                ? Center(
                    child: Text(
                      message as String,
                      style: ShadTheme.of(context).textTheme.h3,
                    ),
                  )
                : (message is Widget)
                ? message as Widget
                : throw Exception('must be either widget or a string'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 8,
            children: [
              if (menuItems == null) ...[
                if (PageManager.of(context).canPop())
                  ShadButton.ghost(
                    onPressed: PageManager.of(context).pop,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(clIcons.pagePop),
                        const Text('Back'),
                      ],
                    ),
                  ),
                ShadButton.ghost(
                  onPressed: () => PageManager.of(context).home(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(clIcons.navigateHome),
                      const Text('Home'),
                    ],
                  ),
                ),
              ] else
                ...menuItems!.map((e) {
                  return ShadButton.ghost(
                    onPressed: e.onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e.icon),
                        Text(e.title),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }
}
