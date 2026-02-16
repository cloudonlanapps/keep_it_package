import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Menu extends StatelessWidget {
  const Menu({required this.menuItems, super.key});
  final List<CLMenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(128 + 64, 128 + 64, 128 + 64, 128 + 64),
            blurRadius: 20, // soften the shadow
            offset: Offset(
              10, // Move to right 10  horizontally
              5, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 18, top: 8, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: menuItems
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ShadButton.ghost(
                      onPressed: () async {
                        if (context.mounted) {
                          await e.onTap?.call();
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            e.icon,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          Text(
                            e.title,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
