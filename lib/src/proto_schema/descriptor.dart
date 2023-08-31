part of 'proto_schema.dart';

typedef PbTypes = FieldDescriptorProto_Type;
typedef MapKeyTypes = MpbMapTypeMsg_KeyTypeEnm;
typedef ScalarTypes = MpbScalarTypeEnm;

typedef TypePath = IList<String>;
typedef TypeCoordinates = ({String fileName, TypePath typePath});
typedef MessagePath = (FileDescriptorProto, DescriptorProto);
typedef EnumDescriptorCoordinates = (FileDescriptorProto, DescriptorProto);

TypePath typeNamePath({
  @ext required String typeName,
}) {
  final path = typeName.split('.');
  assert(path.first == '');
  return path.skip(1).toIList();
}

typedef ResolvedMessage = ({
  FileDescriptorProto fileDescriptor,
  DescriptorProto messageDescriptor,
});
typedef ResolvedEnum = ({
  FileDescriptorProto fileDescriptor,
  EnumDescriptorProto enumDescriptor,
});

typedef ReferencedMsg<M extends Msg> = ({
  ReferenceMsg reference,
  M msg,
});

typedef SchemaCollection = ({
  IList<ReferencedMsg<MessageMsg>> messages,
  IList<ReferencedMsg<EnumMsg>> enums,
});

typedef CreateTypeReference = ReferenceMsg Function(
  TypeCoordinates typeCoordinates,
);

typedef ReferenceSequence = Call<int>;

ReferenceSequence memoryReferenceSequence({
  final int startAt = 0,
}) {
  var nextSequenceNumber = startAt;
  return () => nextSequenceNumber++;
}

CreateTypeReference memoryCreateTypeReference({
  ReferenceSequence? referenceSequence,
}) {
  final effectiveReferenceSequence =
      referenceSequence ?? memoryReferenceSequence();

  final references = <TypeCoordinates, ReferenceMsg>{};

  return (typeCoordinates) {
    return references.putIfAbsent(
      typeCoordinates,
      () => MpbReferenceMsg$.create(
        referenceId: Int64(
          effectiveReferenceSequence(),
        ),
      ),
    );
  };
}

Future<SchemaLookupByName> descriptorSchemaLookupByName({
  @ext required FileDescriptorSet fileDescriptorSet,
}) async {
  final schemaCollection = fileDescriptorSet.descriptorSchemaCollection(
    messageReference: memoryCreateTypeReference(),
  );

  final schemaBuilder =
      schemaCollection.schemaCollectionToResolveCtx().createSchemaBuilder();

  for (final message in schemaCollection.messages) {
    await schemaBuilder.registerMessage(message.reference);
  }

  final schemaCtx = schemaBuilder.schemaCtx;

  final messageCtxIterable = schemaCollection.messages
      .map((e) => schemaCtx.lookupMessage(e.reference));

  final messageCtxByTypeName = {
    for (final messageCtx in messageCtxIterable)
      messageCtx.messageCtxTypeName(): messageCtx,
  };

  return ComposedSchemaLookupByName(
    lookupMessageCtxByName: messageCtxByTypeName.getOrThrow,
  );
}

MessageCtx lookupMessageCtxOfType<M extends Msg>({
  @ext required SchemaLookupByName schemaLookupByName,
}) {
  return schemaLookupByName.lookupMessageCtxByName(
    M.toString(),
  );
}

SchemaCollection descriptorSchemaCollection({
  @ext required FileDescriptorSet fileDescriptorSet,
  required CreateTypeReference messageReference,
  CreateTypeReference? enumReference,
}) {
  final effectiveEnumReference = enumReference ?? messageReference;
  ResolvedEnum resolveEnum(String typeName) {
    final path = typeName.typeNamePath();

    EnumDescriptorProto? resolve({
      required List<DescriptorProto> messageDescriptors,
      required List<EnumDescriptorProto> enumDescriptors,
      required TypePath typePath,
    }) {
      final singleName = typePath.singleOrNull;

      if (singleName != null) {
        return enumDescriptors.singleWhere((e) => e.name == singleName);
      }

      final name = typePath.first;
      final messageDescriptor = messageDescriptors
          .where(
            (e) => e.name == name,
          )
          .firstOrNull;

      if (messageDescriptor == null) {
        return null;
      }

      final rest = typePath.sublist(1);

      assert(rest.isNotEmpty);

      return resolve(
        messageDescriptors: messageDescriptor.nestedType,
        enumDescriptors: messageDescriptor.enumType,
        typePath: rest,
      );
    }

    for (final fileDescriptor in fileDescriptorSet.file) {
      final enumDescriptor = resolve(
        messageDescriptors: fileDescriptor.messageType,
        enumDescriptors: fileDescriptor.enumType,
        typePath: path,
      );

      if (enumDescriptor != null) {
        return (
          fileDescriptor: fileDescriptor,
          enumDescriptor: enumDescriptor,
        );
      }
    }

    throw typeName;
  }

  ResolvedMessage resolveMessage(String typeName) {
    final path = typeName.typeNamePath();

    DescriptorProto? resolve({
      required List<DescriptorProto> messageDescriptors,
      required TypePath typePath,
    }) {
      final name = typePath.first;
      final messageDescriptor = messageDescriptors
          .where(
            (e) => e.name == name,
          )
          .firstOrNull;

      if (messageDescriptor == null) {
        return null;
      }

      final rest = typePath.sublist(1);

      if (rest.isEmpty) {
        return messageDescriptor;
      } else {
        return resolve(
          messageDescriptors: messageDescriptor.nestedType,
          typePath: rest,
        );
      }
    }

    for (final fileDescriptor in fileDescriptorSet.file) {
      final messageDescriptor = resolve(
        messageDescriptors: fileDescriptor.messageType,
        typePath: path,
      );

      if (messageDescriptor != null) {
        return (
          fileDescriptor: fileDescriptor,
          messageDescriptor: messageDescriptor,
        );
      }
    }

    throw typeName;
  }

  ReferenceMsg enumReferenceFor(String typeName) {
    final resolved = resolveEnum(typeName);

    return messageReference(
      (
        fileName: resolved.fileDescriptor.name,
        typePath: typeName.typeNamePath(),
      ),
    );
  }

  ReferenceMsg messageReferenceFor(String typeName) {
    final resolved = resolveMessage(typeName);

    return messageReference(
      (
        fileName: resolved.fileDescriptor.name,
        typePath: typeName.typeNamePath(),
      ),
    );
  }

  final enums = <ReferencedMsg<EnumMsg>>[];
  final messages = <ReferencedMsg<MessageMsg>>[];

  for (final fileDescriptor in fileDescriptorSet.file) {
    MessageMsg createMessageMsg({
      required DescriptorProto messageDescriptor,
      required MpbReferenceMsg? enclosingMessage,
    }) {
      Iterable<MpbLogicalFieldMsg> logicalFields() sync* {
        final oneofIndicesEmitted = <int>{};

        MpbFieldMsg descriptorToFieldMsg(FieldDescriptorProto fieldDescriptor) {
          final fieldMsg = MpbFieldMsg$.create(
            fieldInfo: MpbFieldInfoMsg$.create(
              description: MpbDescriptionMsg$.create(
                protoName: fieldDescriptor.name,
                jsonName: fieldDescriptor.jsonName,
              ),
              tagNumber: fieldDescriptor.number,
            ),
          );

          MpbSingleTypeMsg singleTypeMsg(
            FieldDescriptorProto fieldDescriptor,
          ) {
            final msg = MpbSingleTypeMsg();
            final scalarType = switch (fieldDescriptor.type) {
              PbTypes.TYPE_DOUBLE => ScalarTypes.TYPE_DOUBLE,
              PbTypes.TYPE_FLOAT => ScalarTypes.TYPE_FLOAT,
              PbTypes.TYPE_INT32 => ScalarTypes.TYPE_INT32,
              PbTypes.TYPE_INT64 => ScalarTypes.TYPE_INT64,
              PbTypes.TYPE_UINT32 => ScalarTypes.TYPE_UINT32,
              PbTypes.TYPE_UINT64 => ScalarTypes.TYPE_UINT64,
              PbTypes.TYPE_SINT32 => ScalarTypes.TYPE_SINT32,
              PbTypes.TYPE_SINT64 => ScalarTypes.TYPE_SINT64,
              PbTypes.TYPE_FIXED32 => ScalarTypes.TYPE_FIXED32,
              PbTypes.TYPE_FIXED64 => ScalarTypes.TYPE_FIXED64,
              PbTypes.TYPE_SFIXED32 => ScalarTypes.TYPE_SFIXED32,
              PbTypes.TYPE_SFIXED64 => ScalarTypes.TYPE_SFIXED64,
              PbTypes.TYPE_BOOL => ScalarTypes.TYPE_BOOL,
              PbTypes.TYPE_STRING => ScalarTypes.TYPE_STRING,
              PbTypes.TYPE_BYTES => ScalarTypes.TYPE_BYTES,
              _ => null,
            };

            if (scalarType != null) {
              msg.scalarType = scalarType;
            } else {
              switch (fieldDescriptor.type) {
                case PbTypes.TYPE_ENUM:
                  msg.enumType = enumReferenceFor(
                    fieldDescriptor.typeName,
                  );
                case PbTypes.TYPE_MESSAGE:
                  msg.messageType = messageReferenceFor(
                    fieldDescriptor.typeName,
                  );
                default:
                  throw fieldDescriptor;
              }
            }

            return msg..freeze();
          }

          void mapField(DescriptorProto mapEntryDescriptor) {
            final [
              keyFieldDescriptor,
              valueFieldDescriptor,
            ] = mapEntryDescriptor.field;

            fieldMsg.mapType = MpbMapTypeMsg$.create(
              keyType: switch (keyFieldDescriptor.type) {
                PbTypes.TYPE_INT32 => MapKeyTypes.TYPE_INT32,
                PbTypes.TYPE_INT64 => MapKeyTypes.TYPE_INT64,
                PbTypes.TYPE_UINT32 => MapKeyTypes.TYPE_UINT32,
                PbTypes.TYPE_UINT64 => MapKeyTypes.TYPE_UINT64,
                PbTypes.TYPE_SINT32 => MapKeyTypes.TYPE_SINT32,
                PbTypes.TYPE_SINT64 => MapKeyTypes.TYPE_SINT64,
                PbTypes.TYPE_FIXED32 => MapKeyTypes.TYPE_FIXED32,
                PbTypes.TYPE_FIXED64 => MapKeyTypes.TYPE_FIXED64,
                PbTypes.TYPE_SFIXED32 => MapKeyTypes.TYPE_SFIXED32,
                PbTypes.TYPE_SFIXED64 => MapKeyTypes.TYPE_SFIXED64,
                PbTypes.TYPE_BOOL => MapKeyTypes.TYPE_BOOL,
                PbTypes.TYPE_STRING => MapKeyTypes.TYPE_STRING,
                _ => throw mapEntryDescriptor,
              },
              valueType: singleTypeMsg(valueFieldDescriptor),
            );
          }

          void repeatedField() {
            fieldMsg.repeatedType = MpbRepeatedTypeMsg$.create(
              singleType: singleTypeMsg(fieldDescriptor),
            );
          }

          switch (fieldDescriptor.label) {
            case FieldDescriptorProto_Label.LABEL_REPEATED:
              if (fieldDescriptor.type ==
                  FieldDescriptorProto_Type.TYPE_MESSAGE) {
                final resolvedMessageDescriptor = resolveMessage(
                  fieldDescriptor.typeName,
                ).messageDescriptor;
                if (resolvedMessageDescriptor.options.mapEntry) {
                  mapField(resolvedMessageDescriptor);
                } else {
                  repeatedField();
                }
              } else {
                repeatedField();
              }
            case FieldDescriptorProto_Label.LABEL_OPTIONAL:
              fieldMsg.singleType = singleTypeMsg(fieldDescriptor);
            case FieldDescriptorProto_Label.LABEL_REQUIRED:
              throw [messageDescriptor.name, fieldDescriptor];
          }

          return fieldMsg..freeze();
        }

        for (final fieldDescriptor in messageDescriptor.field) {
          if (fieldDescriptor.hasOneofIndex()) {
            final oneofIndex = fieldDescriptor.oneofIndex;
            if (!oneofIndicesEmitted.contains(oneofIndex)) {
              oneofIndicesEmitted.add(oneofIndex);

              yield MpbLogicalFieldMsg$.create(
                oneof: MpbOneofMsg$.create(
                  fields: messageDescriptor.field
                      .where(
                        (e) => e.hasOneofIndex() && e.oneofIndex == oneofIndex,
                      )
                      .map(descriptorToFieldMsg),
                ),
              );
            }
          } else {
            yield MpbLogicalFieldMsg$.create(
              physicalField: descriptorToFieldMsg(fieldDescriptor),
            );
          }
        }
      }

      return MpbMessageMsg$.create(
        description: MpbDescriptionMsg$.create(
          protoName: messageDescriptor.name,
        ),
        enclosingMessage: enclosingMessage,
        fields: logicalFields(),
      );
    }

    EnumMsg createEnumMsg({
      required EnumDescriptorProto enumDescriptor,
      required ReferenceMsg? enclosingMessage,
    }) {
      return MpbEnumMsg$.create(
        description: MpbDescriptionMsg$.create(
          protoName: enumDescriptor.name,
        ),
        enclosingMessage: enclosingMessage,
        enumValues: enumDescriptor.value.map(
          (value) {
            return MpbEnumValueMsg$.create(
              description: MpbDescriptionMsg$.create(
                protoName: value.name,
              ),
            ).valueToMapEntry(
              key: value.number,
            );
          },
        ).entriesToMap(),
      );
    }

    ReferenceMsg? enclosingMessage({
      required TypePath parentPath,
    }) {
      return parentPath.isEmpty
          ? null
          : messageReference(
              (
                fileName: fileDescriptor.name,
                typePath: parentPath,
              ),
            );
    }

    void processEnum({
      required TypePath parentPath,
      required EnumDescriptorProto enumDescriptor,
    }) {
      final typePath = parentPath.add(enumDescriptor.name);

      final referenceMsg = effectiveEnumReference(
        (
          fileName: fileDescriptor.name,
          typePath: typePath,
        ),
      );

      final enumMsg = createEnumMsg(
        enumDescriptor: enumDescriptor,
        enclosingMessage: enclosingMessage(
          parentPath: parentPath,
        ),
      );

      enums.add(
        (
          reference: referenceMsg,
          msg: enumMsg,
        ),
      );
    }

    void processMessage({
      required TypePath parentPath,
      required DescriptorProto messageDescriptor,
    }) {
      final typePath = parentPath.add(messageDescriptor.name);

      final referenceMsg = messageReference(
        (
          fileName: fileDescriptor.name,
          typePath: typePath,
        ),
      );

      final messageMsg = createMessageMsg(
        messageDescriptor: messageDescriptor,
        enclosingMessage: enclosingMessage(
          parentPath: parentPath,
        ),
      );

      messages.add(
        (
          reference: referenceMsg,
          msg: messageMsg,
        ),
      );

      for (final enumDescriptor in messageDescriptor.enumType) {
        processEnum(
          parentPath: typePath,
          enumDescriptor: enumDescriptor,
        );
      }
    }

    for (final messageDescriptor in fileDescriptor.messageType) {
      processMessage(
        parentPath: IList(),
        messageDescriptor: messageDescriptor,
      );
    }

    for (final enumDescriptor in fileDescriptor.enumType) {
      processEnum(
        parentPath: IList(),
        enumDescriptor: enumDescriptor,
      );
    }
  }

  return (
    enums: enums.toIList(),
    messages: messages.toIList(),
  );
}
