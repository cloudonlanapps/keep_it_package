import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class BrokenImage extends StatelessWidget {
  const BrokenImage({
    super.key,
  });
  static Widget? cachedWidget;

  @override
  Widget build(BuildContext context) {
    return cachedWidget ??= AspectRatio(
      aspectRatio: 1,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox.square(
          dimension: 64,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Center(
                child: Icon(
                  clIcons.brokenImage,
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget show(Object e, StackTrace st) => const BrokenImage();
}
