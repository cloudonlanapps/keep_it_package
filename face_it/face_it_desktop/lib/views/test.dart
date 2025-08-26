import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// Data model for our panels
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Panel Heading $index',
      expandedValue: 'This is the expanded content for panel $index.',
    );
  });
}

class ExpansionPanelListExample extends StatefulWidget {
  const ExpansionPanelListExample({super.key});

  @override
  State<ExpansionPanelListExample> createState() =>
      _ExpansionPanelListExampleState();
}

class _ExpansionPanelListExampleState extends State<ExpansionPanelListExample> {
  final List<Item> _data = generateItems(15);
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: _data.length,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
        return ExpansionPanelList(
          elevation: 1,
          expansionCallback: (int itemIndex, bool isExpanded) {
            setState(() {
              _data[itemIndex].isExpanded = !isExpanded;
              if (!isExpanded) {
                // Scroll to the item when it is expanded
                _itemScrollController.scrollTo(
                  index: itemIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text(_data[index].headerValue));
              },
              body: ListTile(title: Text(_data[index].expandedValue)),
              isExpanded: _data[index].isExpanded,
            ),
          ],
        );
      },
    );
  }
}
