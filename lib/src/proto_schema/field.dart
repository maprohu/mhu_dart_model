part of 'proto_schema.dart';

@Compose()
abstract class FieldActions {}

@Has()
@Compose()
abstract class FieldCtx implements MessageCtx, FieldActions, LogicalFieldCtx {}

FieldCtx createTopFieldCtx({
  required MessageCtx messageCtx,
  required FieldMsg fieldMsg,
}) {
  return ComposedFieldCtx.merge$(
    messageCtx: messageCtx,
    fieldActions: ComposedFieldActions(),
  );
}
