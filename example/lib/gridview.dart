import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Item Selector + GridView'),
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
    return ItemSelectionController(
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
    );
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
