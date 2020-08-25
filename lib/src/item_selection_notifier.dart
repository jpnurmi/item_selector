// Copyright 2020 J-P Nurmi
//
// ItemSelectionNotifier is based on Flutter's ChangeNotifier:
// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/foundation/change_notifier.dart
//
// Copyright 2014 The Flutter Authors. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'item_selection_types.dart';

abstract class ItemSelectionNotifier {
  /// Adds a [listener] callback for selection changes at any index.
  void addListener(ItemSelectionChangeCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  /// Removes a [listener] callback for selection changes at any index.
  void removeListener(ItemSelectionChangeCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  /// Adds a [listener] callback for selection changes at a specific [index] only.
  void addIndexListener(int index, ItemSelectionChangeCallback listener) {
    assert(_debugAssertNotDisposed());
    if (!_indexListeners.containsKey(index)) {
      _indexListeners[index] = ObserverList<ItemSelectionChangeCallback>();
    }
    _indexListeners[index].add(listener);
  }

  /// Removes a [listener] callback for selection changes at a specific [index] only.
  void removeIndexListener(int index, ItemSelectionChangeCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_indexListeners.containsKey(index)) {
      _indexListeners[index].remove(listener);
    }
  }

  /// Notifies all the registered listeners.
  @protected
  void notifyListeners(int index, bool selected) {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final allListeners = List<ItemSelectionChangeCallback>.from(
          [..._listeners, ...?_indexListeners[index]]);
      for (final listener in allListeners) {
        try {
          listener(index, selected);
        } catch (exception, stack) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: exception,
              stack: stack,
              library: 'item_selector',
              context: ErrorDescription(
                  'while dispatching notifications for $runtimeType'),
              informationCollector: () sync* {
                yield DiagnosticsProperty<ItemSelectionNotifier>(
                  'The $runtimeType sending notification was',
                  this,
                  style: DiagnosticsTreeStyle.errorProperty,
                );
              },
            ),
          );
        }
      }
    }
  }

  /// Discards the listener callbacks. After this method is called, the notifier
  /// object is no longer in a usable state and should be discarded (calls to
  /// [addListener] and [removeListener] will throw after the object is
  /// disposed).
  ///
  /// This method should only be called by the object's owner.
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _indexListeners = null;
    _listeners = null;
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null || _indexListeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  ObserverList<ItemSelectionChangeCallback> _listeners =
      ObserverList<ItemSelectionChangeCallback>();
  HashMap<int, ObserverList<ItemSelectionChangeCallback>> _indexListeners =
      HashMap<int, ObserverList<ItemSelectionChangeCallback>>();
}
