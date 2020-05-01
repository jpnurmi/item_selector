# Item Selector for Flutter

[![pub](https://img.shields.io/pub/v/item_selector.svg)](https://pub.dev/packages/item_selector)
[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![build](https://github.com/jpnurmi/item_selector/workflows/build/badge.svg)
[![codecov](https://codecov.io/gh/jpnurmi/item_selector/branch/master/graph/badge.svg)](https://codecov.io/gh/jpnurmi/item_selector)

A generic [Flutter](https://flutter.dev) item selector that works with
ListView, GridView, Row, Column, or basically any parent widget that
can have indexed child widgets. It supports single-selection by tap,
and multi-selection by long-press and drag with auto-scrolling.

## Preview

| ListView | GridView |
|:---:|:---:|
| ![ListView](https://raw.githubusercontent.com/jpnurmi/item_selector/master/doc/images/listview.gif "ListView") | ![GridView](https://raw.githubusercontent.com/jpnurmi/item_selector/master/doc/images/gridview.gif "GridView") |

| Column | Custom |
|:---:|:---:|
| ![Column](https://raw.githubusercontent.com/jpnurmi/item_selector/master/doc/images/column.gif "Column") | ![Custom](https://raw.githubusercontent.com/jpnurmi/item_selector/master/doc/images/custom.gif "Custom") |

## Usage

To use this package, add `item_selector` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

```dart
ItemSelectionController(
  child: ListView(
    children: List.generate(10, (int index) {
      return ItemSelectionBuilder(
        index: index,
        builder: (BuildContext context, int index, bool selected) {
          return Text('$index: $selected');
        },
      );
    }),
  ),
)
```

## Thanks

Item Selector is based on [Multi Select GridView in Flutter - by Simon Lightfoot](https://gist.github.com/slightfoot/a002dd1e031f5f012f810c6d5da14a11).
