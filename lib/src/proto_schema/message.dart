part of 'proto_schema.dart';

@Has()
typedef LogicalFieldsList = IList<LogicalFieldCtx>;

@Has()
typedef LookupFieldIndex = FieldIndex Function(FieldMsg fieldMsg);

@Has()
typedef GenericBuilderInfo = BuilderInfo;

@Has()
typedef EnclosingMessage = MessageCtx?;

@Has()
typedef DefaultGenericMsg = GenericMsg;

@Has()
typedef CreateGenericMsg = CreateValue<GenericMsg>;

@Compose()
abstract class MessageCtx
    implements
        SchemaCtx,
        HasCallLogicalFieldsList,
        HasLookupFieldIndex,
        HasCallGenericBuilderInfo,
        HasCallEnclosingMessage,
        HasCallDefaultGenericMsg,
        HasCreateGenericMsg,
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
    final tagNumbersSorted = messageMsg
        .messageMsgPhysicalFields()
        .map((e) => e.fieldInfo.tagNumber)
        .toList()
      ..sort();

    return {
      for (final (index, tag) in tagNumbersSorted.indexed) tag: index,
    };
  });

  late final builderInfo = run(() {
    final builderInfo = BuilderInfo(
      messageCtx
          .messageCtxPath()
          .map((e) => e.messageMsg.description.protoName)
          .join("."),
      createEmptyInstance: messageCtx.createGenericMsg,
    )..hasRequiredFields = false;

    final fields = messageCtx
        .messageFieldCtxIterable()
        .sortedBy<num>((e) => e.fieldCtxTagNumber());

    for (final fieldCtx in fields) {
      fieldCtx.fieldCtxAddBuilderInfoField(
        builderInfo: builderInfo,
      );
    }

    return builderInfo;
  });

  late final defaultGenericMsg = GenericMsg(info: builderInfo);

  GenericMsg createGenericMsg() => GenericMsg(info: builderInfo);

  return messageCtx = ComposedMessageCtx.schemaCtx(
    schemaCtx: schemaCtx,
    callLogicalFieldsList: () => logicalFieldsList,
    referenceMsg: referenceMsg,
    lookupFieldIndex: (fieldMsg) =>
        tagNumberToIndex[fieldMsg.fieldInfo.tagNumber] ?? (throw fieldMsg),
    callGenericBuilderInfo: () => builderInfo,
    callDefaultGenericMsg: () => defaultGenericMsg,
    createGenericMsg: createGenericMsg,
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

String messageCtxTypeName({
  @ext required MessageCtx messageCtx,
}) {
  return messageCtx
      .messageCtxPath()
      .map((e) => e.messageMsg.description.protoName)
      .join('_');
}

Iterable<FieldMsg> messageMsgPhysicalFields({
  @ext required MessageMsg messageMsg,
}) sync* {
  for (final field in messageMsg.fields) {
    switch (field.type) {
      case MpbLogicalFieldMsg_Type$physicalField(:final physicalField):
        yield physicalField;
      case MpbLogicalFieldMsg_Type$oneof(:final oneof):
        yield* oneof.fields;
      default:
        throw field;
    }
  }
}

Iterable<FieldCtx> messageFieldCtxIterable({
  @ext required MessageCtx messageCtx,
}) sync* {
  for (final logicalFieldCtx in messageCtx.callLogicalFieldsList()) {
    switch (logicalFieldCtx) {
      case FieldCtx():
        yield logicalFieldCtx;
      case OneofCtx():
        yield* logicalFieldCtx.callOneofOptionsList();
    }
  }
}
