import 'dart:math';

import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Customized Item Selector'),
        ),
        body: ExamplePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selection = RectSelection(4);
    return ItemSelectionController(
      selection: selection,
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: List.generate(100, (int index) {
          return ItemSelectionBuilder(
            index: index,
            builder: buildExampleItem,
          );
        }),
      ),
      onSelectionStart: selection.start,
      onSelectionUpdate: selection.update,
    );
  }
}

class RectSelection extends ItemSelection {
  RectSelection(this.columns);

  final int columns;
  ItemSelection oldSelection = ItemSelection();

  int rowAt(int index) => index ~/ columns;
  int columnAt(int index) => index % columns;
  int indexAt(int row, int column) => column + row * columns;

  bool start(int start, int end) {
    oldSelection = ItemSelection(start, end);
    return false;
  }

  bool update(int start, int end) {
    // calculate rectangular selection bounds
    final startRow = rowAt(min(start, end));
    final endRow = rowAt(max(start, end));
    final startColumn = columnAt(min(start, end));
    final endColumn = columnAt(max(start, end));

    // construct new rectangular selection row by row
    final newSelection = ItemSelection();
    for (int r = startRow; r <= endRow; ++r) {
      final startIndex = indexAt(r, startColumn);
      final endIndex = indexAt(r, endColumn);
      newSelection.add(startIndex, endIndex);
    }

    // apply selection changes
    addAll(ItemSelection.copy(newSelection)..removeAll(oldSelection));
    removeAll(ItemSelection.copy(oldSelection)..removeAll(newSelection));

    oldSelection = newSelection;
    return true;
  }
}

Widget buildExampleItem(BuildContext context, int index, bool selected) {
  return Card(
    margin: EdgeInsets.all(10),
    elevation: selected ? 2 : 10,
    child: GridTile(
      child: Center(child: FlutterLogo()),
      footer: Padding(
        padding: const EdgeInsets.all(2),
        child: Text(
          index.toString(),
          textAlign: TextAlign.end,
        ),
      ),
    ),
  );
}
