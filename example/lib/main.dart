import 'dart:math';

import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

void main() => runApp(ExampleApp());

final pages = <PageData>[
  PageData(
    title: 'Column',
    icon: Icons.view_agenda,
    builder: (_) => ColumnPage(),
  ),
  PageData(
    title: 'ListView',
    icon: Icons.view_headline,
    builder: (_) => ListViewPage(),
  ),
  PageData(
    title: 'GridView',
    icon: Icons.view_module,
    builder: (_) => GridViewPage(),
  ),
];

class PageData {
  const PageData({this.title, this.icon, this.builder});
  final String? title;
  final IconData? icon;
  final WidgetBuilder? builder;
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Selector',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Item Selector + ${pages[currentPage].title}'),
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 246),
          child: Container(
            key: ValueKey<int>(currentPage),
            child: pages[currentPage].builder!(context),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (index) => setState(() => currentPage = index),
          items: pages
              .map((page) => BottomNavigationBarItem(
                    icon: Icon(page.icon),
                    title: Text(page.title!),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

Widget buildListItem(BuildContext context, int index, bool selected) {
  return Card(
    margin: EdgeInsets.all(10),
    elevation: selected ? 2 : 10,
    child: ListTile(
      leading: FlutterLogo(),
      contentPadding: EdgeInsets.all(10),
      title: Text(index.toString()),
    ),
  );
}

class ColumnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ItemSelectionController(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return ItemSelectionBuilder(
            index: index,
            builder: buildListItem,
          );
        }),
      ),
    );
  }
}

class ListViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ItemSelectionController(
      child: ListView.builder(
        itemCount: 100,
        itemBuilder: (BuildContext context, int index) {
          return ItemSelectionBuilder(
            index: index,
            builder: buildListItem,
          );
        },
      ),
    );
  }
}

Widget buildGridItem(BuildContext context, int index, bool selected) {
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

class GridViewPage extends StatelessWidget {
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
            builder: buildGridItem,
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
