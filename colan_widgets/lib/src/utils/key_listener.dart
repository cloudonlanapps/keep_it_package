import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CLKeyListener extends StatefulWidget {
  const CLKeyListener({
    required this.child,
    required this.keyHandler,
    super.key,
  });
  final Widget child;
  final Map<LogicalKeyboardKey, VoidCallback> keyHandler;

  @override
  CLKeyListenerState createState() => CLKeyListenerState();
}

class CLKeyListenerState extends State<CLKeyListener> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (widget.keyHandler.keys.contains(event.logicalKey)) {
            widget.keyHandler[event.logicalKey]!();
          }
        }
      },
      child: widget.child,
    );
  }
}
