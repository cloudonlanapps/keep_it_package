import 'package:flutter/material.dart';

class MoveToLabel extends StatelessWidget {
  const MoveToLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32 + 8,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 4,
            endIndent: 4,
          ),
        ),
        Text(
          'Move to',
        ),
        Flexible(
          flex: 5,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 4,
            endIndent: 4,
          ),
        ),
      ],
    );
  }
}
