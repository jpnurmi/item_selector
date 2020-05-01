import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Item Selector + Column'),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
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
    child: ListTile(
      leading: FlutterLogo(),
      contentPadding: EdgeInsets.all(10),
      title: Text(index.toString()),
    ),
  );
}
