import 'package:flutter_test/flutter_test.dart';

import 'package:item_selector/item_selector.dart';

class ItemSelectionListener {
  ItemSelectionListener(ItemSelection selection, int start, int end) {
    for (int i = start; i <= end; ++i) {
      selection.addIndexListener(i, (int index, bool selected) {
        expect(index, i);
        _notifications[i] = selected;
      });
    }
  }

  Map takeAll() {
    var result = Map.of(_notifications);
    _notifications.clear();
    return result;
  }

  Map _notifications = {};
}

void main() {
  final Matcher throwsStateError = throwsA(isA<StateError>());

  test('empty', () {
    expect(ItemSelection(), isEmpty);
    expect(ItemSelection(0, 1), isNotEmpty);
  });

  test('iterable', () {
    ItemSelection empty = ItemSelection();
    expect(empty.isEmpty, isTrue);
    expect(empty.isNotEmpty, isFalse);
    expect(empty.first, isNull);
    expect(empty.last, isNull);
    expect(empty.length, 0);
    expect(() => empty.single, throwsStateError);

    final single = ItemSelection(0, 0);
    expect(single.isEmpty, isFalse);
    expect(single.isNotEmpty, isTrue);
    expect(single.first, isNotNull);
    expect(single.last, isNotNull);
    expect(single.length, 1);
    expect(single.single, 0);

    final selection = ItemSelection();
    selection.add(7, 9);
    selection.add(13, 15);
    selection.add(1, 3);

    expect(selection.toList(), [1, 2, 3, 7, 8, 9, 13, 14, 15]);
    expect(selection.isEmpty, isFalse);
    expect(selection.isNotEmpty, isTrue);
    expect(selection.first, 1);
    expect(selection.last, 15);
    expect(selection.length, 9);
    expect(() => selection.single, throwsStateError);
  });

  test('contains', () {
    expect(ItemSelection().contains(0), isFalse);
    expect(ItemSelection(0, 1).contains(0), isTrue);
    expect(ItemSelection(0, 1).contains(2), isFalse);

    final selection = ItemSelection(1, 2);
    selection.add(4, 5);
    expect(selection.contains(0), isFalse);
    expect(selection.contains(1), isTrue);
    expect(selection.contains(2), isTrue);
    expect(selection.contains(3), isFalse);
    expect(selection.contains(4), isTrue);
    expect(selection.contains(5), isTrue);
    expect(selection.contains(6), isFalse);
  });

  test('add', () {
    final selection = ItemSelection();
    expect(selection.toList(), []);

    ItemSelectionListener listener = ItemSelectionListener(selection, 0, 5);

    selection.add(0, 2);
    expect(selection.toList(), [0, 1, 2]);
    expect(listener.takeAll(), {0: true, 1: true, 2: true});

    selection.add(4, 5);
    expect(selection.toList(), [0, 1, 2, 4, 5]);
    expect(listener.takeAll(), {4: true, 5: true});

    selection.add(3);
    expect(selection.toList(), [0, 1, 2, 3, 4, 5]);
    expect(listener.takeAll(), {3: true});

    selection.add(3);
    expect(selection.toList(), [0, 1, 2, 3, 4, 5]);
    expect(listener.takeAll(), {});
  });

  test('remove', () {
    final selection = ItemSelection(0, 5);
    expect(selection.toList(), [0, 1, 2, 3, 4, 5]);

    ItemSelectionListener listener = ItemSelectionListener(selection, 0, 5);

    selection.remove(3);
    expect(selection.toList(), [0, 1, 2, 4, 5]);
    expect(listener.takeAll(), {3: false});

    selection.remove(4, 5);
    expect(selection.toList(), [0, 1, 2]);
    expect(listener.takeAll(), {4: false, 5: false});

    selection.remove(0, 2);
    expect(selection.toList(), []);
    expect(listener.takeAll(), {0: false, 1: false, 2: false});

    selection.remove(3);
    expect(selection.toList(), []);
    expect(listener.takeAll(), {});
  });

  test('replace', () {
    final selection = ItemSelection(0, 5);
    expect(selection.toList(), [0, 1, 2, 3, 4, 5]);

    ItemSelectionListener listener = ItemSelectionListener(selection, 0, 5);

    selection.replace(1, 4);
    expect(selection.toList(), [1, 2, 3, 4]);
    expect(listener.takeAll(), {0: false, 5: false});

    selection.replace(2, 5);
    expect(selection.toList(), [2, 3, 4, 5]);
    expect(listener.takeAll(), {1: false, 5: true});

    selection.replace(0, 2);
    expect(selection.toList(), [0, 1, 2]);
    expect(
        listener.takeAll(), {0: true, 1: true, 3: false, 4: false, 5: false});

    selection.replace(0, 2);
    expect(selection.toList(), [0, 1, 2]);
    expect(listener.takeAll(), {});
  });

  test('clear', () {
    final selection = ItemSelection(0, 2);
    expect(selection.toList(), [0, 1, 2]);

    ItemSelectionListener listener = ItemSelectionListener(selection, 0, 2);

    selection.clear();
    expect(selection.toList(), []);
    expect(listener.takeAll(), {0: false, 1: false, 2: false});
  });
}
