import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:item_selector/item_selector.dart';

import 'item_selection_test_widget.dart';

void main() {
  final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

  testWidgets('tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      ItemSelectionTestWidget(
        itemCount: 3,
        builder: (context, index, selected) {
          return Text('$index: $selected');
        },
      ),
    );

    expect(find.text('0: false'), findsOneWidget);
    expect(find.text('1: false'), findsOneWidget);
    expect(find.text('2: false'), findsOneWidget);

    await tester.tap(find.text('1: false'));
    await tester.pumpAndSettle();
    expect(find.text('1: true'), findsOneWidget);
    expect(find.text('1: false'), findsNothing);

    await tester.tap(find.text('0: false'));
    await tester.pumpAndSettle();
    expect(find.text('0: true'), findsOneWidget);
    expect(find.text('0: false'), findsNothing);
    expect(find.text('1: false'), findsOneWidget);

    await tester.tap(find.text('2: false'));
    await tester.pumpAndSettle();
    expect(find.text('2: true'), findsOneWidget);
    expect(find.text('2: false'), findsNothing);
    expect(find.text('0: false'), findsOneWidget);
  });

  testWidgets('drag', (WidgetTester tester) async {
    final selection = ItemSelection();

    await tester.pumpWidget(
      ItemSelectionTestWidget(
        itemCount: 3,
        selection: selection,
        builder: (context, index, selected) {
          return Text('$index: $selected');
        },
      ),
    );

    expect(selection, isEmpty);
    expect(find.text('0: false'), findsOneWidget);
    expect(find.text('1: false'), findsOneWidget);
    expect(find.text('2: false'), findsOneWidget);

    TestGesture gesture =
        await tester.startGesture(tester.getCenter(find.text('0: false')));
    await tester.pumpAndSettle(kLongPressTimeout);
    expect(find.text('0: true'), findsOneWidget);
    expect(selection.toList(), [0]);

    await gesture.moveTo(tester.getCenter(find.text('2: false')));
    await tester.pumpAndSettle();
    expect(find.text('1: true'), findsOneWidget);
    expect(find.text('2: true'), findsOneWidget);
    expect(selection.toList(), [0, 1, 2]);

    await gesture
        .moveBy(Offset(0, tester.getSize(find.text('0: true')).height));
    await tester.pumpAndSettle();
    expect(find.text('0: true'), findsOneWidget);
    expect(find.text('1: true'), findsOneWidget);
    expect(find.text('2: true'), findsOneWidget);
    expect(selection.toList(), [0, 1, 2]);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('0: true'), findsOneWidget);
    expect(find.text('1: true'), findsOneWidget);
    expect(find.text('2: true'), findsOneWidget);
    expect(selection.toList(), [0, 1, 2]);
  });

  testWidgets('callbacks', (WidgetTester tester) async {
    final selection = ItemSelection();

    bool handle = false;
    var starts = [];
    var updates = [];
    var ends = [];

    final controller = ItemSelectionTestWidget(
      itemCount: 3,
      selection: selection,
      onSelectionStart: (int start, int end) {
        starts.add(start);
        return handle;
      },
      onSelectionUpdate: (int start, int end) {
        updates.add(end);
        return handle;
      },
      onSelectionEnd: (int start, int end) {
        ends.add(end);
        return handle;
      },
      builder: (context, index, selected) {
        return Text('$index: $selected');
      },
    );

    await tester.pumpWidget(controller);

    // tap
    await tester.tap(find.text('1: false'));
    await tester.pumpAndSettle();
    expect(starts, [1]);
    expect(updates, isEmpty);
    expect(ends, [1]);
    expect(selection.toList(), [1]);

    // drag with non-handling callbacks
    TestGesture gesture =
        await tester.startGesture(tester.getCenter(find.text('0: false')));
    await tester.pumpAndSettle(kLongPressTimeout);
    expect(starts, [1, 0]);
    expect(updates, isEmpty);
    expect(ends, [1]);
    expect(selection.toList(), [0]);

    await gesture.moveTo(tester.getCenter(find.text('1: false')));
    await tester.pumpAndSettle();
    expect(starts, [1, 0]);
    expect(updates, [1]);
    expect(ends, [1]);
    expect(selection.toList(), [0, 1]);

    await gesture.moveTo(tester.getCenter(find.text('2: false')));
    await tester.pumpAndSettle();
    expect(starts, [1, 0]);
    expect(updates, [1, 2]);
    expect(ends, [1]);
    expect(selection.toList(), [0, 1, 2]);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(starts, [1, 0]);
    expect(updates, [1, 2]);
    expect(ends, [1, 2]);
    expect(selection.toList(), [0, 1, 2]);

    // drag with handling callbacks
    handle = true;
    starts.clear();
    updates.clear();
    ends.clear();
    selection.clear();
    await tester.pumpAndSettle();

    gesture =
        await tester.startGesture(tester.getCenter(find.text('0: false')));
    await tester.pumpAndSettle(kLongPressTimeout);
    expect(starts, [0]);
    expect(updates, isEmpty);
    expect(ends, isEmpty);
    expect(selection, isEmpty);

    await gesture.moveTo(tester.getCenter(find.text('1: false')));
    await tester.pumpAndSettle();
    expect(starts, [0]);
    expect(updates, [1]);
    expect(ends, isEmpty);
    expect(selection, isEmpty);

    await gesture.moveTo(tester.getCenter(find.text('2: false')));
    await tester.pumpAndSettle();
    expect(starts, [0]);
    expect(updates, [1, 2]);
    expect(ends, isEmpty);
    expect(selection, isEmpty);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(starts, [0]);
    expect(updates, [1, 2]);
    expect(ends, [2]);
    expect(selection, isEmpty);
  });
}
