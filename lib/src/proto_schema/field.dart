part of 'proto_schema.dart';

// @Has()
// sealed class FieldActions {}

@Compose()
abstract class FieldBits implements HasCallFieldCoordinates, HasTypeActions {}

@Has()
@Compose()
abstract class FieldCtx
    implements MessageCtx, LogicalFieldActions, FieldBits, LogicalFieldCtx {}

FieldCtx createTopFieldCtx({
  required MessageCtx messageCtx,
  required FieldMsg fieldMsg,
}) {
  return ComposedFieldCtx.merge$(
    messageCtx: messageCtx,
    logicalFieldActions: ComposedLogicalFieldActions(
      fieldProtoName: fieldMsg.fieldInfo.description.protoName,
    ),
    fieldBits: createFieldBits(
      messageCtx: messageCtx,
      fieldMsg: fieldMsg,
    ),
  );
}

FieldBits createFieldBits({
  required MessageCtx messageCtx,
  required FieldMsg fieldMsg,
}) {
  return ComposedFieldBits(
    typeActions: fieldMsg.fieldMsgTypeActions(),
    callFieldCoordinates: lazy(
      () => ComposedFieldCoordinates(
        fieldIndex: messageCtx.lookupFieldIndex(fieldMsg),
        tagNumberValue: fieldMsg.fieldInfo.tagNumber,
      ),
    ),
  );
}
