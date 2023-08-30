part of 'proto_schema.dart';

@Has()
typedef OneofOptionsList = IList<OneofOptionCtx>;

@Compose()
abstract class OneofCtx
    implements
        MessageCtx,
        LogicalFieldActions,
        LogicalFieldCtx,
        HasCallOneofOptionsList {}

@Compose()
abstract class OneofOptionCtx implements OneofCtx, FieldActions, FieldCtx {}

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
      fieldName: oneofMsg.description.name,
    ),
    callOneofOptionsList: () => oneofOptionsList,
  );
}

OneofOptionCtx createOneofOptionCtx({
  @ext required OneofCtx oneofCtx,
  @ext required FieldMsg fieldMsg,
}) {
  return ComposedOneofOptionCtx.merge$(
    oneofCtx: oneofCtx,
    fieldActions: ComposedFieldActions(),
  );
}
