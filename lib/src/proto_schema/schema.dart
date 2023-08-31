part of 'proto_schema.dart';

@Has()
typedef LookupMessage = Lookup<MpbReferenceMsg, MessageCtx>;

@Has()
typedef LookupEnum = Lookup<MpbReferenceMsg, EnumCtx>;

@Compose()
@Has()
abstract class SchemaCtx implements HasLookupEnum, HasLookupMessage {}

@Has()
typedef RegisterMessage = Future<MessageCtx> Function(
  ReferenceMsg referenceMsg,
);

@Compose()
abstract class SchemaBuilder implements HasSchemaCtx, HasRegisterMessage {}

SchemaBuilder createSchemaBuilder({
  required ResolveCtx resolveCtx,
}) {
  final enumLookup = <ReferenceMsg, EnumCtx>{};
  final messageLookup = <ReferenceMsg, MessageCtx>{};

  final schemaCtx = ComposedSchemaCtx(
    lookupEnum: enumLookup.getOrThrow,
    lookupMessage: messageLookup.getOrThrow,
  );

  Future<MessageCtx> processMessage({
    required ReferenceMsg referenceMsg,
  }) async {
    Future<EnumCtx> processEnum({
      required ReferenceMsg referenceMsg,
    }) async {
      final existing = enumLookup[referenceMsg];

      if (existing != null) {
        return existing;
      }

      final enumMsg = await resolveCtx.resolveEnumMsg(
        referenceMsg: referenceMsg,
      );

      final enumCtx = enumMsg.createEnumCtx();

      enumLookup[referenceMsg] = enumCtx;

      final enclosingMessage = enumMsg.enclosingMessageOpt;
      if (enclosingMessage != null) {
        await processMessage(referenceMsg: enclosingMessage);
      }

      return enumCtx;
    }

    final existing = messageLookup[referenceMsg];

    if (existing != null) {
      return existing;
    }

    final messageMsg = await resolveCtx.resolveMessageMsg(
      referenceMsg: referenceMsg,
    );

    final messageCtx = createMessageCtx(
      schemaCtx: schemaCtx,
      messageMsg: messageMsg,
      referenceMsg: referenceMsg,
    );

    messageLookup[referenceMsg] = messageCtx;

    Iterable<Future> processSingleType({
      required MpbSingleTypeMsg singleTypeMsg,
    }) sync* {
      switch (singleTypeMsg.type) {
        case MpbSingleTypeMsg_Type$messageType(:final messageType):
          yield processMessage(referenceMsg: messageType);
        case MpbSingleTypeMsg_Type$enumType(:final enumType):
          yield processEnum(referenceMsg: enumType);
        default:
      }
    }

    Iterable<Future> processPhysicalField(
      FieldMsg fieldMsg,
    ) sync* {
      switch (fieldMsg.type) {
        case MpbFieldMsg_Type$singleType(:final singleType):
          yield* processSingleType(singleTypeMsg: singleType);
        case MpbFieldMsg_Type$repeatedType(:final repeatedType):
          yield* processSingleType(singleTypeMsg: repeatedType.singleType);
        case MpbFieldMsg_Type$mapType(:final mapType):
          yield* processSingleType(singleTypeMsg: mapType.valueType);
        default:
          throw fieldMsg;
      }
    }

    final enclosingMessage = messageMsg.enclosingMessageOpt;
    await Future.wait([
      ...messageMsg.messageMsgPhysicalFields().expand(processPhysicalField),
      if (enclosingMessage != null)
        processMessage(referenceMsg: enclosingMessage),
    ]);

    return messageCtx;
  }

  return ComposedSchemaBuilder(
    schemaCtx: schemaCtx,
    registerMessage: (referenceMsg) async {
      return await processMessage(
        referenceMsg: referenceMsg,
      );
    },
  );
}

MessageCtx schemaLookupMessage({
  @ext required SchemaCtx schemaCtx,
  @ext required ReferenceMsg referenceMsg,
}) {
  return schemaCtx.lookupMessage(referenceMsg);
}

EnumCtx schemaLookupEnum({
  @ext required SchemaCtx schemaCtx,
  @ext required ReferenceMsg referenceMsg,
}) {
  return schemaCtx.lookupEnum(referenceMsg);
}
