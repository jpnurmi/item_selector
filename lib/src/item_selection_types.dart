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

/// Specifies how an item selection controller responds to user interaction.
///
/// See also [ItemSelectionController()].
enum ItemSelectionMode {
  /// No interactive selection.
  none,

  /// Single-selection by tap.
  single,

  /// Multi-selection by long-press and drag (default).
  multi,
}

/// Signature for a callback function that is called by [ItemSelectionController]
/// when items are interactively selected by the user.
typedef ItemSelectionActionCallback = bool Function(int start, int end);

/// Signature for a callback function that is called by [ItemSelection] when an
/// item selection state changes to [selected] at the specified [index].
typedef ItemSelectionChangeCallback = void Function(int index, bool selected);

/// Signature for a builder function that is called by [ItemSelectionBuilder] to
/// create a widget for a given [index] and [selected] state.
typedef ItemSelectionWidgetBuilder = Widget Function(
    BuildContext context, int index, bool selected);

class ItemSelectionMetaData {
  final int index;
  ItemSelectionMetaData({required this.index});
}
