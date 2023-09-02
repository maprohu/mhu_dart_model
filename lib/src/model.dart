import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';
import 'package:protobuf/protobuf.dart';

import '../proto.dart';

import 'model.dart' as $lib;

part 'model.g.dart';

CmnTimestampMsg cmnTimestampFromDateTime(DateTime dateTime) => CmnTimestampMsg()
  ..millisSinceEpoch = dateTime.millisecondsSinceEpoch.toDouble()
  ..freeze();

extension ModelDateTimeX on DateTime {
  CmnTimestampMsg get toCmnTimestampMsg => cmnTimestampFromDateTime(this);

  CmnDateValueMsg get toCmnDateValueMsg => CmnDateValueMsg()
    ..year = year
    ..month = CmnMonthEnm.valueOf(month)!
    ..day = day
    ..freeze();
}

extension CmnTimestampX on CmnTimestampMsg {
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(
        millisSinceEpoch.toInt(),
      );
}

extension CmnDimensionsMsgX on CmnDimensionsMsg {
  double get aspectRatio => height == 0 ? 1 : (width / height);
}

extension CmnDateValueMsgX on CmnDateValueMsg {
  String get displayLabel => [
        year.toString().padLeft(4, '0'),
        month.value.toString().padLeft(2, '0'),
        day.toString().padLeft(2, '0'),
      ].join('-');

  DateTime get toDateTime => DateTime(year, month.value, day);
}

extension CmnEnumOptionMsgX on StringMapEntry<CmnEnumOptionMsg> {
  String? get labelOpt => value.labelOpt;

  String get labelOrKey => labelOpt ?? key;

  bool get hidden => value.hidden;
}

Comparator<StringMapEntry<CmnEnumOptionMsg>> cmnEnumOptionsComparator =
    compareMany([
  compareByFieldNatural(
    (t) => t.value.orderOpt,
    comparator: nullLast(compareTo<num>),
  ),
  compareByField(
    (t) => t.labelOrKey,
  ),
]);

CmnAny cmnAnyFromBytes({
  @ext required List<int> bytes,
}) {
  return CmnAny()
    ..data = bytes
    ..freeze();
}

CmnAny cmnAnyFromMsg<M extends Msg>({
  @ext required M msg,
}) {
  return msg.writeToBuffer().cmnAnyFromBytes();
}
