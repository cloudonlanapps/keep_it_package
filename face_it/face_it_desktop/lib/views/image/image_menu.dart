import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';

import '../utils/menu_link_active_when_socket_connected.dart';

class ImageMenu extends StatelessWidget {
  const ImageMenu({required this.menuItems, super.key});

  final List<CLMenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: menuItems
            .map(
              (e) => Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: MenuLinkActiveWhenSocketConnected(menuItem: e),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
