import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:item_selector/item_selector.dart';

import 'item_selection_test_widget.dart';

void main() {
  final Matcher throwsAssertionError = throwsA(isA<AssertionError>());

  testWidgets('errors', (WidgetTester tester) async {
    // builder required
    expect(() => ItemSelectionBuilder(index: 0, builder: null),
        throwsAssertionError);

    // invalid index
    expect(
        () => ItemSelectionBuilder(
              index: -1,
              builder: (_, __, ___) {
                return Container();
              },
            ),
        throwsAssertionError);

    // missing controller
    final expectFlutterError = expectAsync0(() {});
    FlutterError.onError = (_) {
      expectFlutterError();
    };
    await tester.pumpWidget(ItemSelectionBuilder(
      index: 0,
      builder: (_, __, ___) {
        return Container();
      },
    ));
  });

  testWidgets('rebuild', (WidgetTester tester) async {
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

    expect(find.text('0: false'), findsOneWidget);
    expect(find.text('1: false'), findsOneWidget);
    expect(find.text('2: false'), findsOneWidget);

    selection.add(1);
    await tester.pumpAndSettle();
    expect(find.text('1: true'), findsOneWidget);
    expect(find.text('1: false'), findsNothing);

    selection.add(0);
    await tester.pumpAndSettle();
    expect(find.text('0: true'), findsOneWidget);
    expect(find.text('0: false'), findsNothing);

    selection.add(2);
    await tester.pumpAndSettle();
    expect(find.text('2: true'), findsOneWidget);
    expect(find.text('2: false'), findsNothing);

    selection.remove(1);
    await tester.pumpAndSettle();
    expect(find.text('1: true'), findsNothing);
    expect(find.text('1: false'), findsOneWidget);
  });
}
