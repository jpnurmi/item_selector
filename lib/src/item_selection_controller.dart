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
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'item_selection.dart';
import 'item_selection_hit_tester.dart';
import 'item_selection_types.dart';

/// Controls a selection within indexed child widgets.
///
/// ItemSelectionController detects tap, long-press, and drag gestures,
/// and performs appropriate selection actions based on its selection mode.
///
/// ### Example
///
///     Widget build(BuildContext context) {
///       return ItemSelectionController(
///         child: ListView.builder(
///           itemCount: 100,
///           itemBuilder: (BuildContext context, int index) {
///             return ItemSelectionBuilder(
///               index: index,
///               builder: (BuildContext context, int index, bool selected) {
///                 return Text('$index: $selected');
///               },
///             );
///           },
///         ),
///       );
///     }
class ItemSelectionController extends StatefulWidget {
  final Widget child;
  final ItemSelection _selection;
  final ItemSelectionMode _selectionMode;
  final ItemSelectionActionCallback _onSelectionStart;
  final ItemSelectionActionCallback _onSelectionUpdate;
  final ItemSelectionActionCallback _onSelectionEnd;
  final EdgeInsets _scrollInsets;
  final Duration _scrollDuration;

  /// Creates an item selection controller.
  ///
  /// A [selection] may be provided to tell ItemSelectionController to operate
  /// on a specific instance. This allows you to add listeners on the selection,
  /// for example.
  ///
  /// [selectionMode] specifies whether the controller performs single-selection
  /// by tap, or multi-selection by long-press and drag gestures. The default
  /// selection mode is [ItemSelectionMode.multi].
  ///
  /// The `onSelectionStart`, `onSelectionUpdate`, and `onSelectionEnd` callbacks
  /// are called when an interactive item selection starts, updates, or ends,
  /// respectively. Return `true` to indicate that the callback has handled the
  /// action, or `false` to let the controller perform the default action.
  ///
  /// The default selection actions:
  ///   - `onSelectionStart:
  ///     - clear any existing selection
  ///     - add a new selection with [start] index
  ///   - `onSelectionUpdate`:
  ///     - replace the existing selection with [start] to [end]
  ///   - `onSelectionEnd`:
  ///     - none, reserved for future use
  ///
  /// Furthermore, should a selection occur on a child widget that is partly
  /// outside the viewport, [scrollInsets] and [scrollDuration] may be specified
  /// to control auto-scrolling. The defaults are _48 px_ and _125 ms_.
  ItemSelectionController(
      {Key key,
      @required this.child,
      ItemSelection selection,
      ItemSelectionMode selectionMode,
      ItemSelectionActionCallback onSelectionStart,
      ItemSelectionActionCallback onSelectionUpdate,
      ItemSelectionActionCallback onSelectionEnd,
      EdgeInsets scrollInsets,
      Duration scrollDuration})
      : _selection = selection ?? ItemSelection(),
        _selectionMode = selectionMode ?? ItemSelectionMode.multi,
        _scrollInsets = scrollInsets ?? const EdgeInsets.all(48),
        _scrollDuration = scrollDuration ?? const Duration(milliseconds: 125),
        _onSelectionStart = onSelectionStart,
        _onSelectionUpdate = onSelectionUpdate,
        _onSelectionEnd = onSelectionEnd,
        super(key: key);

  /// Returns the current selection.
  ItemSelection get selection => _selection;

  bool _startSelection(int start, int end) {
    if (_onSelectionStart == null) return false;
    return _onSelectionStart(start, end);
  }

  bool _updateSelection(int start, int end) {
    if (_onSelectionUpdate == null) return false;
    return _onSelectionUpdate(start, end);
  }

  bool _endSelection(int start, int end) {
    if (_onSelectionEnd == null) return false;
    return _onSelectionEnd(start, end);
  }

  /// Returns an ItemSelectionController instance for the given build [context],
  /// or `null` if not found.
  static ItemSelectionController of(BuildContext context) {
    final _ItemSelectionScope scope =
        context.dependOnInheritedWidgetOfExactType<_ItemSelectionScope>();
    return scope?.controller;
  }

  @override
  _ItemSelectionControllerState createState() =>
      _ItemSelectionControllerState();
}

class _ItemSelectionControllerState extends State<ItemSelectionController> {
  int _start = -1;
  int _end = -1;

  @override
  Widget build(BuildContext context) {
    final canSelect = widget._selectionMode != ItemSelectionMode.none;
    final multiSelect = widget._selectionMode == ItemSelectionMode.multi;
    return _ItemSelectionScope(
      controller: widget,
      child: ItemSelectionHitTester(
        child: GestureDetector(
          child: widget.child,
          onTapUp: canSelect ? _onTapUp : null,
          onLongPressStart: canSelect ? _onLongPressStart : null,
          onLongPressMoveUpdate: multiSelect ? _onLongPressMoveUpdate : null,
          onLongPressEnd: multiSelect ? _onLongPressEnd : null,
        ),
      ),
    );
  }

  void _onTapUp(TapUpDetails details) {
    final index = _hitTestAt(details.localPosition);
    _startSelection(index);
    _endSelection(index);
  }

  void _onLongPressStart(LongPressStartDetails details) {
    final index = _hitTestAt(details.localPosition);
    _startSelection(index);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final index = _hitTestAt(details.localPosition);
    _updateSelection(index);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    final index = _hitTestAt(details.localPosition);
    _updateSelection(index);
    _endSelection(index);
  }

  int _hitTestAt(Offset position) {
    final RenderItemSelectionHitTester hitTester = context.findRenderObject();
    return hitTester?.hitTestAt(
            position, widget._scrollInsets, widget._scrollDuration) ??
        -1;
  }

  void _startSelection(int index) {
    if (index < 0) return;
    _start = _end = index;
    if (!widget._startSelection(index, index)) {
      widget.selection.clear();
      widget.selection.add(index);
    }
  }

  void _updateSelection(int index) {
    if (index < 0 || _start < 0 || _end == index) return;
    _end = index;
    if (!widget._updateSelection(_start, index)) {
      widget.selection.replace(_start, index);
    }
  }

  void _endSelection(int index) {
    if (index < 0 || _start < 0) return;
    widget._endSelection(_start, index);
    _start = _end = -1;
  }
}

class _ItemSelectionScope extends InheritedWidget {
  final ItemSelectionController controller;

  const _ItemSelectionScope({
    Key key,
    Widget child,
    this.controller,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_ItemSelectionScope old) {
    return controller != old.controller;
  }
}
