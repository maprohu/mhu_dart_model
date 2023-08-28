part of 'proto_schema.dart';

@Has()
sealed class LogicalFieldCtx implements MessageCtx {}

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
