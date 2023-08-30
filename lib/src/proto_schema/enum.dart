part of 'proto_schema.dart';

@Compose()
abstract class EnumCtx implements HasEnumMsg {}

EnumCtx createEnumCtx({
  @ext required EnumMsg enumMsg,
}) {
  return ComposedEnumCtx(
    enumMsg: enumMsg,
  );
}
