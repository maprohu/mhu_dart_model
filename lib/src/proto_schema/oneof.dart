part of 'proto_schema.dart';

@Has()
typedef OneofOptionsList = IList<OneofOptionCtx>;

@Compose()
abstract class OneofCtx
    implements
        MessageCtx,
        LogicalFieldActions,
        LogicalFieldCtx,
        HasCallOneofOptionsList,
        HasOneofMsg {}

@Compose()
abstract class OneofOptionCtx implements OneofCtx, FieldBits, FieldCtx {}

OneofCtx createOneofCtx({
  @ext required MessageCtx messageCtx,
  required OneofMsg oneofMsg,
}) {
  late final OneofCtx oneofCtx;
  late final oneofOptionsList =
      oneofMsg.fields.map(oneofCtx.createOneofOptionCtx$).toIList();
  return oneofCtx = ComposedOneofCtx.merge$(
    messageCtx: messageCtx,
    logicalFieldActions: ComposedLogicalFieldActions(
      fieldProtoName: oneofMsg.description.protoName,
    ),
    callOneofOptionsList: () => oneofOptionsList,

    oneofMsg: oneofMsg,
  );
}

OneofOptionCtx createOneofOptionCtx({
  @ext required OneofCtx oneofCtx,
  @ext required FieldMsg fieldMsg,
}) {
  return ComposedOneofOptionCtx.merge$(
    oneofCtx: oneofCtx,
    fieldMsg: fieldMsg,
    fieldBits: createFieldBits(
      messageCtx: oneofCtx,
      fieldMsg: fieldMsg,
    ),
  );
}

void oneofAddToBuilderInfo({
  @extHas required OneofMsg oneofMsg,
  required int oneofIndex,
  @ext required BuilderInfo builderInfo,
}) {
  builderInfo.oo(
    oneofIndex,
    oneofMsg.fields.map((e) => e.fieldInfo.tagNumber).toList()..sort(),
  );
}
