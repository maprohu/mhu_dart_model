import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_pbschema/mhu_dart_pbschema.dart';
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

CmnAnyMsg cmnAnyFromMsgBytes({
  @ext required List<int> bytes,
}) {
  return CmnAnyMsg()
    ..ensureSingleValue().messageValue = bytes
    ..freeze();
}

CmnAnyMsg cmnAnyFromMsg<M extends Msg>({
  @ext required M msg,
}) {
  return msg.writeToBuffer().cmnAnyFromMsgBytes();
}

typedef AnyMsg = CmnAnyMsg;

typedef AnyMsgUpdates = Updates<AnyMsg>;

CmnAnyMsg anyMsgFromUpdates({
  @ext required AnyMsgUpdates anyMsgUpdates,
}) {
  return CmnAnyMsg()
    ..also(anyMsgUpdates)
    ..freeze();
}

CmnSingleMsg singleMsgString({
  @ext required String stringValue,
}) {
  return CmnSingleMsg()
    ..ensureScalarValue().stringValue = stringValue
    ..freeze();
}


typedef AnyMsgLift<T> = Lift<AnyMsg, T>;

final anyMsgBinaryLift = AnyMsg.create.createBinaryProtoLift();
