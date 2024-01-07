import 'package:flutter/material.dart';

enum Col { col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12 }

class EnumValues<T> {
  Map<int, T> map;
  late Map<T, int> reverseMap;

  EnumValues(this.map);

  Map<T, int> get reverse => map.map((k, v) => MapEntry(v, k));
}

EnumValues<Col> cols = EnumValues({
  1: Col.col1,
  2: Col.col2,
  3: Col.col3,
  4: Col.col4,
  5: Col.col5,
  6: Col.col6,
  7: Col.col7,
  8: Col.col8,
  9: Col.col9,
  10: Col.col10,
  11: Col.col11,
  12: Col.col12,
});

double width(Col? lg, Col? md, Col? sm, BuildContext context) {
  if (MediaQuery.sizeOf(context).width > 997) {
    if (lg != null) {
      return MediaQuery.sizeOf(context).width * (cols.reverse[lg]! / 12);
    } else {
      return MediaQuery.sizeOf(context).width;
    }
  } else if (MediaQuery.sizeOf(context).width > 767 && MediaQuery.sizeOf(context).width < 997) {
    if (md != null) {
      return MediaQuery.sizeOf(context).width * (cols.reverse[md]! / 12);
    } else {
      return MediaQuery.sizeOf(context).width;
    }
  } else {
    if (sm != null) {
      return MediaQuery.sizeOf(context).width * (cols.reverse[sm]! / 12);
    } else {
      return MediaQuery.sizeOf(context).width;
    }
  }
}
