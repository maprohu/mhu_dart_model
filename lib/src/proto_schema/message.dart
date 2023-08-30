part of 'proto_schema.dart';

@Has()
typedef LogicalFieldsList = IList<LogicalFieldCtx>;

@Has()
typedef LookupFieldIndex = FieldIndex Function(FieldMsg fieldMsg);

@Has()
typedef GenericBuilderInfo = BuilderInfo;

@Has()
typedef EnclosingMessage = MessageCtx?;

@Compose()
abstract class MessageCtx
    implements
        SchemaCtx,
        HasCallLogicalFieldsList,
        HasLookupFieldIndex,
        HasCallGenericBuilderInfo,
        HasCallEnclosingMessage,
        HasReferenceMsg,
        HasMessageMsg {}

MessageCtx createMessageCtx({
  @ext required SchemaCtx schemaCtx,
  required MessageMsg messageMsg,
  required ReferenceMsg referenceMsg,
}) {
  late final MessageCtx messageCtx;

  late final logicalFieldsList =
      messageMsg.fields.map(messageCtx.createLogicalFieldCtx$).toIList();

  late final tagNumberToIndex = run(() {
    final tagNumbersSorted = messageMsg.fields.expand((field) sync* {
      switch (field.type) {
        case MpbLogicalFieldMsg_Type$physicalField(:final physicalField):
          yield physicalField.fieldInfo.tagNumber;
        case MpbLogicalFieldMsg_Type$oneof(:final oneof):
          for (final option in oneof.fields) {
            yield option.fieldInfo.tagNumber;
          }
        default:
          throw field;
      }
    }).toList()
      ..sort();

    final result = <TagNumberValue, FieldIndex>{};

    tagNumbersSorted.forEachIndexed(
      (index, tagNumber) {
        result[tagNumber] = index;
      },
    );

    return result;
  });

  return messageCtx = ComposedMessageCtx.schemaCtx(
    schemaCtx: schemaCtx,
    callLogicalFieldsList: () => logicalFieldsList,
    referenceMsg: referenceMsg,
    lookupFieldIndex: (fieldMsg) =>
        tagNumberToIndex[fieldMsg.fieldInfo.tagNumber] ?? (throw fieldMsg),
    callGenericBuilderInfo: lazy(() {
      final builderInfo = BuilderInfo(
        messageCtx
            .messageCtxPath()
            .map((e) => e.messageMsg.description.protoName)
            .join("."),
        createEmptyInstance: messageCtx.createGenericMsg,
      )..hasRequiredFields = false;
      return builderInfo;
    }),
    callEnclosingMessage: lazy(() {
      return messageMsg.enclosingMessageOpt?.schemaLookupMessage(
        schemaCtx: schemaCtx,
      );
    }),
    messageMsg: messageMsg,
  );
}

Iterable<MessageCtx> messageCtxPath({
  @ext required MessageCtx messageCtx,
}) {
  return messageCtx
      .finiteIterable((item) => item.callEnclosingMessage())
      .toList()
      .reversed;
}
