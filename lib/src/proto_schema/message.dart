part of 'proto_schema.dart';

@Has()
typedef LogicalFieldsList = IList<LogicalFieldCtx>;

@Compose()
abstract class MessageCtx
    implements SchemaCtx, HasCallLogicalFieldsList, HasReferenceMsg {}

MessageCtx createMessageCtx({
  @ext required SchemaCtx schemaCtx,
  required MessageMsg messageMsg,
  required ReferenceMsg referenceMsg,
}) {
  late final MessageCtx messageCtx;

  late final logicalFieldsList =
      messageMsg.fields.map(messageCtx.createLogicalFieldCtx$).toIList();

  return messageCtx = ComposedMessageCtx(
    callLogicalFieldsList: () => logicalFieldsList,
    referenceMsg: referenceMsg,
  );
}
