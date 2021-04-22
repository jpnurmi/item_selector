// MIT License
//
// Copyright (c) 2020 J-P Nurmi
//
// The ItemSelector library is based on:
// Multi Select GridView in Flutter - by Simon Lightfoot:
// https://gist.github.com/slightfoot/a002dd1e031f5f012f810c6d5da14a11
//
// Copyright (c) 2019 Simon Lightfoot
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Thanks to Hugo Passos.
//
import 'package:flutter/widgets.dart';

import 'item_selection_controller.dart';
import 'item_selection_types.dart';

/// Builds itself based on selection state changes.
///
/// ItemSelectionBuilder is used in conjunction with [ItemSelectionController].
/// Widget rebuilding is scheduled by appropriate selection changes in the
/// controller.
///
/// Notice that you must tell ItemSelectionBuilder the [index] it represents,
/// and a [builder] method that is called when the selection state of that
/// particular index changes.
///
/// ### Example
///
///     Widget build(BuildContext context) {
///       return ItemSelectionController(
///         child: Column(
///           children: List.generate(5, (int index) {
///             // tell the builder which index it represents
///             return ItemSelectionBuilder(
///               index: index,
///               builder: (BuildContext context, int index, bool selected) {
///                 // build a selectable item
///                 return Text('$index: $selected');
///               },
///             );
///           }),
///         ),
///       );
///     }
class ItemSelectionBuilder extends StatefulWidget {
  /// Creates an item selection builder.
  ///
  /// Notice that you must tell ItemSelectionBuilder the [index] it represents,
  /// and a [builder] method that is called when the selection state of that
  /// particular index changes.
  ItemSelectionBuilder({
    Key? key,
    required this.index,
    ItemSelectionController? controller,
    required ItemSelectionWidgetBuilder builder,
  })  : assert(index != -1),
        _controller = controller,
        _builder = builder,
        super(key: key ?? ValueKey(index));

  /// The index of this builder widget.
  final int index;

  @override
  _ItemSelectionBuilderState createState() => _ItemSelectionBuilderState();

  final ItemSelectionWidgetBuilder _builder;
  final ItemSelectionController? _controller;
}

class _ItemSelectionBuilderState extends State<ItemSelectionBuilder> {
  bool _selected = false;
  ItemSelectionController? _controller;

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: ItemSelectionMetaData(index: widget.index),
      child: widget._builder(context, widget.index, _selected),
    );
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.selection
          .removeIndexListener(widget.index, _updateSelection);
    }
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateController();
  }

  @override
  void didUpdateWidget(ItemSelectionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._controller != oldWidget._controller) _updateController();
  }

  void _updateController() {
    final newController =
        widget._controller ?? ItemSelectionController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
            'No ItemSelectionController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'ItemSelectionController using the "controller" property, or you must ensure that there '
            'is a ItemSelectionController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());

    if (newController == _controller) return;

    final index = widget.index;
    if (_controller != null) {
      _controller!.selection.removeIndexListener(index, _updateSelection);
    }
    _controller = newController;
    if (_controller != null) {
      _controller!.selection.addIndexListener(index, _updateSelection);
      _updateSelection(index, _controller!.selection.contains(index));
    }
  }

  void _updateSelection(int index, bool selected) {
    assert(index == widget.index);
    if (_selected != selected) {
      setState(() {
        _selected = selected;
      });
    }
  }
}
