part of 'proto_schema.dart';

@Has()
typedef FieldProtoName = String;


// @Has()
// typedef ReadLogicalField<F> = ReadAttribute<Msg, F>;

@Compose()
abstract class LogicalFieldActions<F>
    implements HasFieldProtoName {}

@Has()
sealed class LogicalFieldCtx implements LogicalFieldActions, MessageCtx {}

LogicalFieldCtx createLogicalFieldCtx({
  @ext required MessageCtx messageCtx,
  @ext required LogicalFieldMsg logicalFieldMsg,
}) {
  return switch (logicalFieldMsg.type) {
    MpbLogicalFieldMsg_Type$oneof(:final oneof) => createOneofCtx(
        messageCtx: messageCtx,
        oneofMsg: oneof,
      ),
    MpbLogicalFieldMsg_Type$physicalField(:final physicalField) =>
      createTopFieldCtx(
        messageCtx: messageCtx,
        fieldMsg: physicalField,
      ),
    MpbLogicalFieldMsg_Type$notSet$() => throw logicalFieldMsg,
  };
}
