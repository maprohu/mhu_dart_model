

import '../proto.dart';

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

extension CmnEnumOptionMsgX on CmnEnumOptionMsg {
  String get labelOrValue => labelOpt ?? value;

  String labelOrValueOr(String fallback) => labelOpt ?? valueOpt ?? fallback;
}

