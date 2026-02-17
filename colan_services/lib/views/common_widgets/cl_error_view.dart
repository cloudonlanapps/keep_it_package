import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'basic_page_service.dart';

class CLErrorView extends StatelessWidget {
  const CLErrorView({
    required this.errorMessage,
    super.key,
    this.errorDetails,
  });

  final String errorMessage;
  final String? errorDetails;

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
          Text(trim(errorMessage), style: ShadTheme.of(context).textTheme.h3),
          ...[
            const SizedBox(
              height: 32,
            ),
            if (errorDetails != null)
              Text(
                errorDetails!,
                textAlign: TextAlign.justify,
                style: ShadTheme.of(context).textTheme.muted,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
              ),
          ],
        ],
      ),
    );
  }

  String trim(String msg) {
    final parts = msg.split(':');
    return parts.last;
  }
}
