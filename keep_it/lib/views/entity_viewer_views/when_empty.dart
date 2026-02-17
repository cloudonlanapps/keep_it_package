import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../common_widgets/basic_page_service.dart';

class WhenEmpty extends StatelessWidget {
  const WhenEmpty({
    super.key,
    this.onReset,
  });
  final Future<bool?> Function()? onReset;

  @override
  Widget build(BuildContext context) {
    return BasicPageService.message(
      message: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.folder,
            size: 32,
            color: Theme.of(context).colorScheme.error,
          ),
          Text('Nothing to show', style: ShadTheme.of(context).textTheme.h3),
          const SizedBox(
            height: 32,
          ),
          Text(
            'Import Photos and Videos from the Gallery or using Camera. '
            'Connect to server to view your home collections '
            "using 'Cloud on LAN' service.",
            textAlign: TextAlign.justify,
            style: ShadTheme.of(context).textTheme.muted,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}
