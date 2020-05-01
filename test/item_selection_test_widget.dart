import 'package:flutter/widgets.dart';

import 'package:item_selector/item_selector.dart';

class ItemSelectionTestWidget extends Container {
  ItemSelectionTestWidget(
      {int itemCount,
      ItemSelectionActionCallback onSelectionStart,
      ItemSelectionActionCallback onSelectionUpdate,
      ItemSelectionActionCallback onSelectionEnd,
      ItemSelectionWidgetBuilder builder,
      ItemSelection selection})
      : super(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ItemSelectionController(
              selection: selection,
              onSelectionStart: onSelectionStart,
              onSelectionUpdate: onSelectionUpdate,
              onSelectionEnd: onSelectionEnd,
              child: Column(
                children: List.generate(itemCount, (index) {
                  return ItemSelectionBuilder(
                    index: index,
                    builder: builder,
                  );
                }),
              ),
            ),
          ),
        );
}
