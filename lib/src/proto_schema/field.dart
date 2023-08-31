part of 'proto_schema.dart';

// @Has()
// sealed class FieldActions {}

@Compose()
abstract class FieldBits implements HasCallFieldCoordinates, HasTypeActions {}

@Has()
@Compose()
abstract class FieldCtx
    implements
        MessageCtx,
        LogicalFieldActions,
        FieldBits,
        LogicalFieldCtx,
        HasFieldMsg {}

FieldCtx createTopFieldCtx({
  required MessageCtx messageCtx,
  required FieldMsg fieldMsg,
}) {
  return ComposedFieldCtx.merge$(
    messageCtx: messageCtx,
    fieldMsg: fieldMsg,
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
    typeActions: fieldMsg.fieldMsgTypeActions(
      messageCtx: messageCtx,
    ),
    callFieldCoordinates: lazy(
      () => ComposedFieldCoordinates(
        fieldIndex: messageCtx.lookupFieldIndex(fieldMsg),
        tagNumberValue: fieldMsg.fieldInfo.tagNumber,
      ),
    ),
  );
}

TagNumberValue fieldCtxTagNumber({
  @ext required FieldCtx fieldCtx,
}) {
  return fieldCtx.fieldMsg.fieldInfo.tagNumber;
}
