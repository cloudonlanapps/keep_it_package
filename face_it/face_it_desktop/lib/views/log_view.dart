import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/server_io.dart';

class LogView extends ConsumerStatefulWidget {
  const LogView({super.key});

  @override
  ConsumerState<LogView> createState() => _LogViewState();
}

class _LogViewState extends ConsumerState<LogView> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(serverIOProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
          data: (serverIO) {
            return MessageBox(messages: serverIO.messages);
          },
        );
  }
}

class MessageBox extends StatefulWidget {
  const MessageBox({
    super.key,
    required this.messages,
    this.horizontalScroller,
    this.verticalScroller,
  });
  final List<String> messages;
  final ScrollController? verticalScroller;
  final ScrollController? horizontalScroller;

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  final ScrollController verticalScroller = ScrollController();
  final ScrollController horizontalScroller = ScrollController();
  bool userScrolled = false;
  bool atEndOfScroll = false;
  @override
  void initState() {
    super.initState();
    verticalScroller.addListener(verticalScrollListener);
    _scrollToBottomLeft();
  }

  @override
  void dispose() {
    verticalScroller.removeListener(verticalScrollListener);
    verticalScroller.dispose();
    horizontalScroller.dispose();
    super.dispose();
  }

  void verticalScrollListener() {
    if (verticalScroller.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        userScrolled = true;
      });
    }

    // Check if the current scroll position is at the very end
    if (verticalScroller.position.pixels ==
        verticalScroller.position.maxScrollExtent) {
      if (!atEndOfScroll) {
        setState(() {
          atEndOfScroll = true;
          print('Reached the end of the scrollable area.');
        });
      }
    } else {
      if (atEndOfScroll) {
        setState(() {
          atEndOfScroll = false;
          print('Moved away from the end.');
        });
      }
    }
  }

  // Helper method to auto-scroll
  void _scrollToBottomLeft() {
    if (!userScrolled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (verticalScroller.hasClients) {
          verticalScroller.jumpTo(verticalScroller.position.maxScrollExtent);
          horizontalScroller.jumpTo(0);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MessageBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.length != oldWidget.messages.length) {
      _scrollToBottomLeft();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: 'W',
            style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 14),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final int maxLength = widget.messages.fold(
          0,
          (maxLen, element) => max(maxLen, element.length),
        );

        final double calculatedWidth = max(
          constraints.maxWidth,
          (textPainter.width.ceil() * maxLength).toDouble(),
        );

        return Stack(
          children: [
            Listener(
              onPointerSignal: (PointerSignalEvent event) {
                // Check if the event is a PointerScrollEvent
                if (event is PointerScrollEvent) {
                  // Check if the shift key is pressed. The `event.synthesized` property
                  // is not reliable, so this is the best way to handle it.
                  if (HardwareKeyboard.instance.physicalKeysPressed.contains(
                        PhysicalKeyboardKey.shiftLeft,
                      ) ||
                      HardwareKeyboard.instance.physicalKeysPressed.contains(
                        PhysicalKeyboardKey.shiftRight,
                      )) {
                    // Apply the horizontal scroll offset
                    horizontalScroller.animateTo(
                      horizontalScroller.offset + event.scrollDelta.dy,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                }
              },
              child: Scrollbar(
                controller: horizontalScroller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: horizontalScroller,
                  physics: AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  child: SizedBox(
                    width: calculatedWidth,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: verticalScroller,
                      itemCount: widget.messages.length,
                      itemBuilder: (context, index) {
                        if (widget.messages[index] == "@Divider") {
                          return const Divider(
                            thickness: 2,
                            color: Colors.grey,
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            //"W" * maxLength + 'X',
                            widget.messages[index],
                            style: GoogleFonts.robotoMono(
                              color: Colors.white,
                              fontSize: 14,
                            ),

                            maxLines: 1, // ensure single line
                            // overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (!atEndOfScroll)
              Align(
                alignment: Alignment.bottomCenter,
                child: ShadBadge.outline(
                  onPressed: () {
                    setState(() {
                      _scrollToBottomLeft();
                      userScrolled = false;
                    });
                  },
                  child: const Icon(
                    Icons.arrow_downward_sharp,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
