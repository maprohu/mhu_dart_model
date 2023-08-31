part of 'proto_schema.dart';

@Has()
typedef ResolveReference = Future<Bytes> Function(ReferenceMsg referenceMsg);

@Compose()
abstract class ResolveCtx implements HasResolveReference {}

Future<M> resolveMsg<M extends Msg>({
  @ext required ResolveCtx resolveCtx,
  @ext required ReferenceMsg referenceMsg,
  required CreateValue<M> createMsg,
}) async {
  final bytes = await resolveCtx.resolveReference(referenceMsg);

  return createMsg()
    ..mergeFromBuffer(bytes)
    ..freeze();
}

Future<MessageMsg> resolveMessageMsg({
  @ext required ResolveCtx resolveCtx,
  @ext required ReferenceMsg referenceMsg,
}) {
  return resolveMsg(
    resolveCtx: resolveCtx,
    referenceMsg: referenceMsg,
    createMsg: MessageMsg.new,
  );
}

Future<EnumMsg> resolveEnumMsg({
  @ext required ResolveCtx resolveCtx,
  @ext required ReferenceMsg referenceMsg,
}) {
  return resolveMsg(
    resolveCtx: resolveCtx,
    referenceMsg: referenceMsg,
    createMsg: EnumMsg.new,
  );
}

ResolveCtx schemaCollectionToResolveCtx({
  @ext required SchemaCollection schemaCollection,
}) {
  final resolveLookup = {
    for (final message in schemaCollection.messages)
      message.reference: message.msg.writeToBuffer(),
    for (final enm in schemaCollection.enums)
      enm.reference: enm.msg.writeToBuffer(),
  };

  return ComposedResolveCtx(
    resolveReference: (referencedMsg) async {
      return resolveLookup[referencedMsg] ?? (throw referencedMsg);
    },
  );
}