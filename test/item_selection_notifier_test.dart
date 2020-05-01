import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:item_selector/src/item_selection_notifier.dart';

class TestSelectionNotifier extends ItemSelectionNotifier {}

void main() {
  final Matcher throwsFlutterError = throwsA(isA<FlutterError>());

  test('notify', () {
    ItemSelectionNotifier notifier = TestSelectionNotifier();
    notifier.notifyListeners(0, true);

    var b = [];
    var i = [];
    var b00 = [];
    var b01 = [];

    var c = (index, selected) {
      i.add(index);
      b.add(selected);
    };

    var c00 = (index, selected) {
      expect(index, 0);
      b00.add(selected);
    };

    var c01 = (index, selected) {
      expect(index, 0);
      b01.add(selected);
    };

    notifier.addListener(c);
    notifier.addIndexListener(0, c00);
    notifier.addIndexListener(0, c01);

    notifier.notifyListeners(0, false);
    expect(i, [0]);
    expect(b, [false]);
    expect(b00, [false]);
    expect(b01, [false]);

    notifier.notifyListeners(1, true);
    expect(i, [0, 1]);
    expect(b, [false, true]);
    expect(b00, [false]);
    expect(b01, [false]);

    notifier.removeListener(c);
    notifier.removeIndexListener(0, c01);

    notifier.notifyListeners(0, true);
    expect(i, [0, 1]);
    expect(b, [false, true]);
    expect(b00, [false, true]);
    expect(b01, [false]);
  });

  test('dispose', () {
    ItemSelectionNotifier notifier = TestSelectionNotifier();
    notifier.dispose();
    expect(() => notifier.notifyListeners(0, true), throwsFlutterError);
  });
}
