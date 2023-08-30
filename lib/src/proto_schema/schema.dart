part of 'proto_schema.dart';

@Has()
typedef MessageLookup = Lookup<MpbReferenceMsg, MessageCtx>;

@Has()
typedef EnumLookup = Lookup<MpbReferenceMsg, EnumCtx>;

@Compose()
@Has()
abstract class SchemaCtx implements HasEnumLookup, HasMessageLookup {}

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
    enumLookup: enumLookup.getOrThrow,
    messageLookup: messageLookup.getOrThrow,
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

    Iterable<Future> processPhysicalField({
      required FieldMsg fieldMsg,
    }) sync* {
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

    Iterable<Future> processFields() sync* {
      for (final logicalField in messageMsg.fields) {
        switch (logicalField.type) {
          case MpbLogicalFieldMsg_Type$physicalField(:final physicalField):
            yield* processPhysicalField(fieldMsg: physicalField);
          case MpbLogicalFieldMsg_Type$oneof(:final oneof):
            for (final physicalField in oneof.fields) {
              yield* processPhysicalField(fieldMsg: physicalField);
            }
          default:
            throw logicalField;
        }
      }
    }

    final enclosingMessage = messageMsg.enclosingMessageOpt;
    await Future.wait([
      ...processFields(),
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
  return schemaCtx.messageLookup(referenceMsg);
}

EnumCtx schemaLookupEnum({
  @ext required SchemaCtx schemaCtx,
  @ext required ReferenceMsg referenceMsg,
}) {
  return schemaCtx.enumLookup(referenceMsg);
}
