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
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'item_selection_types.dart';

class ItemSelectionHitTester extends SingleChildRenderObjectWidget {
  ItemSelectionHitTester({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderItemSelectionHitTester createRenderObject(BuildContext context) =>
      RenderItemSelectionHitTester();
}

class RenderItemSelectionHitTester extends RenderProxyBox {
  int hitTestAt(
      Offset position, EdgeInsets scrollInsets, Duration scrollDuration) {
    final result = BoxHitTestResult();
    final hit = hitTestChildren(result, position: _withinPaintBounds(position));
    if (hit) {
      for (final entry in result.path) {
        final target = entry.target;
        if (target is RenderMetaData) {
          target.showOnScreen(
            duration: scrollDuration,
            rect: scrollInsets.inflateRect(Offset.zero & target.size),
          );
          final metaData = target.metaData;
          if (metaData is ItemSelectionMetaData) {
            return metaData.index;
          }
        }
      }
    }
    return -1;
  }

  Offset _withinPaintBounds(Offset position) {
    double clamp(double val, double a, double b) {
      return max(a, min(val, b));
    }

    return Offset(
      clamp(position.dx, paintBounds.left + 1, paintBounds.right - 1),
      clamp(position.dy, paintBounds.top + 1, paintBounds.bottom - 1),
    );
  }
}
