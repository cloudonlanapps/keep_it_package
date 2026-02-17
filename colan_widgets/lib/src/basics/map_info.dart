import 'package:flutter/material.dart';

class MapInfo extends StatefulWidget {
  const MapInfo(
    this.map, {
    super.key,
    this.title,
  });
  final Map<String, dynamic> map;
  final String? title;

  @override
  State<MapInfo> createState() => _MapInfoState();
}

class _MapInfoState extends State<MapInfo> {
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    widget.title ?? 'Details:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        show = !show;
                      });
                    },
                    child: Align(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          show ? 'Hide' : 'show',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (show)
              for (final entry in widget.map.entries)
                TableRow(
                  children: [
                    TableCell(child: PaddedText(entry.key)),
                    TableCell(child: PaddedText(entry.value.toString())),
                  ],
                ),
          ],
        ),
      ],
    );
  }
}

class PaddedText extends StatelessWidget {
  const PaddedText(this.text, {super.key, this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: style,
      ),
    );
  }
}
