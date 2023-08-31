part of 'proto_schema.dart';

@Has()
typedef SingleTypeGeneric = GenericFunction1<Object>;

@Has()
typedef PbFieldTypeCode = int;

@Has()
typedef PbRepeatedFieldTypeCode = int;

@Has()
typedef PbDefaultOrMarker = Object?;

@Has()
typedef PbCreateBuilderFunc = CreateBuilderFunc?;

@Has()
typedef PbValueOfFunc = ValueOfFunc?;

@Has()
typedef PbEnumValues = List<ProtobufEnum>?;

@Has()
typedef PbDefaultEnumValue = ProtobufEnum?;

@Has()
typedef CollectionElementTypeActions<V extends Object> = SingleTypeActions<V>;

@Has()
typedef MapKeyTypeActions<V extends Object> = SingleTypeActions<V>;

@Has()
typedef UpdateBuilderInfoType = void Function(
  BuilderInfo builderInfo,
  TagNumberValue tagNumber,
);

@Has()
sealed class TypeActions<V> implements HasReadFieldValue<V> {}

@Compose()
abstract class SingleTypeReadWrite<V extends Object>
    implements
        HasSingleTypeGeneric,
        HasReadFieldValue<V?>,
        HasWriteFieldValue<V?> {}

sealed class SingleTypeActions<V extends Object>
    implements
        SingleTypeReadWrite<V>,
        TypeActions<V?>,
        HasWriteFieldValue<V?>,
        HasSingleTypeGeneric,
        HasPbFieldTypeCode,
        HasPbRepeatedFieldTypeCode,
        HasPbCreateBuilderFunc,
        HasPbValueOfFunc,
        HasPbEnumValues,
        HasPbDefaultEnumValue,
        HasPbDefaultOrMarker {}

@Compose()
abstract class ScalarTypeActions<V extends Object>
    implements SingleTypeReadWrite<V>, SingleTypeActions<V> {}

@Compose()
abstract class MessageTypeActions
    implements SingleTypeReadWrite<GenericMsg>, SingleTypeActions<GenericMsg> {}

@Compose()
abstract class EnumTypeActions
    implements
        SingleTypeReadWrite<ProtobufEnum>,
        SingleTypeActions<ProtobufEnum> {}

sealed class CollectionTypeActions<C extends Object, E extends Object>
    implements TypeActions<C>, HasCollectionElementTypeActions<E> {}

@Compose()
abstract class RepeatedTypeActions<V extends Object>
    implements CollectionTypeActions<List<V>, V> {}

@Compose()
abstract class MapTypeActions<K extends Object, V extends Object>
    implements CollectionTypeActions<Map<K, V>, V>, HasMapKeyTypeActions<K> {}

TypeActions fieldMsgTypeActions({
  @ext required FieldMsg fieldMsg,
  required MessageCtx messageCtx,
}) {
  switch (fieldMsg.type) {
    case MpbFieldMsg_Type$singleType(:final singleType):
      return singleType.singleTypeActions(
        messageCtx: messageCtx,
      );
    case MpbFieldMsg_Type$repeatedType(:final repeatedType):
      final singleActions = repeatedType.singleType.singleTypeActions(
        messageCtx: messageCtx,
      );
      return singleActions.singleTypeGeneric(
        <V extends Object>() {
          return ComposedRepeatedTypeActions<V>(
            readFieldValue: (message, fieldIndex) =>
                message.$_getList(fieldIndex),
            collectionElementTypeActions:
                singleActions as CollectionElementTypeActions<V>,
          );
        },
      );
    case MpbFieldMsg_Type$mapType(:final mapType):
      final keyTypeEnm = MpbScalarTypeEnm.valueOf(
        mapType.keyType.value,
      )!;
      final valueActions = mapType.valueType.singleTypeActions(
        messageCtx: messageCtx,
      );
      final mapKeyTypeActions = keyTypeEnm.scalarTypeActions();
      return mapKeyTypeActions.singleTypeGeneric(
        <K extends Object>() {
          return valueActions.singleTypeGeneric(
            <V extends Object>() {
              return ComposedMapTypeActions<K, V>(
                readFieldValue: (message, fieldIndex) =>
                    message.$_getMap(fieldIndex),
                mapKeyTypeActions: mapKeyTypeActions as MapKeyTypeActions<K>,
                collectionElementTypeActions:
                    valueActions as CollectionElementTypeActions<V>,
              );
            },
          );
        },
      );
    default:
      throw fieldMsg;
  }
}

SingleTypeActions<Object> singleTypeActions({
  @ext required MpbSingleTypeMsg singleType,
  required MessageCtx messageCtx,
}) {
  return switch (singleType.type) {
    MpbSingleTypeMsg_Type$scalarType(:final scalarType) =>
      // ignore: unnecessary_cast
      scalarType.scalarTypeActions() as SingleTypeActions,
    MpbSingleTypeMsg_Type$enumType(:final enumType) => enumTypeActions(
        messageCtx: messageCtx,
        enumReferenceMsg: enumType,
      ),
    MpbSingleTypeMsg_Type$messageType(:final messageType) => messageTypeActions(
        messageCtx: messageCtx,
        valueMessageReferenceMsg: messageType,
      ),
    _ => throw singleType,
  };
}

MessageTypeActions messageTypeActions({
  required MessageCtx messageCtx,
  required ReferenceMsg valueMessageReferenceMsg,
}) {
  final valueMessageCtx = messageCtx.lookupMessage(valueMessageReferenceMsg);

  return ComposedMessageTypeActions.singleTypeReadWrite(
    singleTypeReadWrite: enumOrMessageSingleTypeReadWrite(
      messageCtx: messageCtx,
    ),
    pbFieldTypeCode: PbFieldType.OM,
    pbRepeatedFieldTypeCode: PbFieldType.PM,
    pbDefaultOrMarker: valueMessageCtx.callDefaultGenericMsg,
    pbCreateBuilderFunc: valueMessageCtx.createGenericMsg,
  );
}

EnumTypeActions enumTypeActions({
  required MessageCtx messageCtx,
  required ReferenceMsg enumReferenceMsg,
}) {
  final enumCtx = messageCtx.lookupEnum(enumReferenceMsg);

  final enumValues = {
    for (final entry in enumCtx.enumMsg.enumValues.entries) entry.key: entry,
  };

  final enumValueMsgCache = Cache<int, EnumValueEntry>(
    (key) =>
        enumValues[key] ??
        MapEntry(
          key,
          MpbEnumValueMsg$.create(
            description: MpbDescriptionMsg$.create(
              protoName: "UNKNOWN_VALUE_$key",
            ),
          )..freeze(),
        ),
  );

  final protobufEnumCache = Cache<int, ProtobufEnum>(
    (key) {
      return enumCtx.lookupEnumValue(
        enumValueMsgCache.get(key),
      );
    },
  );

  final defaultEnumValue = protobufEnumCache.get(0);

  return ComposedEnumTypeActions.singleTypeReadWrite(
    singleTypeReadWrite: enumOrMessageSingleTypeReadWrite(
      messageCtx: messageCtx,
    ),
    pbFieldTypeCode: PbFieldType.OE,
    pbRepeatedFieldTypeCode: PbFieldType.KE,
    pbDefaultOrMarker: defaultEnumValue,
    pbDefaultEnumValue: defaultEnumValue,
    pbValueOfFunc: protobufEnumCache.get,
    pbEnumValues: enumCtx.enumMsg.enumValues.entries
        .sortedBy<num>((e) => e.key)
        .map(enumCtx.lookupEnumValue)
        .iterableToUnmodifiableList(),
  );
}

ScalarTypeActions scalarTypeActions({
  @ext required MpbScalarTypeEnm scalarTypeEnm,
}) {
  return switch (scalarTypeEnm) {
    ScalarTypes.TYPE_DOUBLE => scalarTypeReadWriteActions<double>(
        reader: (message) => message.$_getN,
        writer: (message) => message.$_setDouble,
        pbFieldTypeCode: PbFieldType.OD,
        pbRepeatedFieldTypeCode: PbFieldType.KD,
      ),
    ScalarTypes.TYPE_FLOAT => scalarTypeReadWriteActions<double>(
        reader: (message) => message.$_getN,
        writer: (message) => message.$_setFloat,
        pbFieldTypeCode: PbFieldType.OF,
        pbRepeatedFieldTypeCode: PbFieldType.KF,
      ),
    ScalarTypes.TYPE_INT32 => scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setSignedInt32,
        pbFieldTypeCode: PbFieldType.O3,
        pbRepeatedFieldTypeCode: PbFieldType.K3,
      ),
    ScalarTypes.TYPE_SINT32 => scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setSignedInt32,
        pbFieldTypeCode: PbFieldType.OS3,
        pbRepeatedFieldTypeCode: PbFieldType.KS3,
      ),
    ScalarTypes.TYPE_SFIXED32 => scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setSignedInt32,
        pbFieldTypeCode: PbFieldType.OSF3,
        pbRepeatedFieldTypeCode: PbFieldType.KSF3,
      ),
    ScalarTypes.TYPE_INT64 => scalarTypeReadWriteActions<Int64>(
        reader: (message) => message.$_getI64,
        writer: (message) => message.$_setInt64,
        pbFieldTypeCode: PbFieldType.O6,
        pbRepeatedFieldTypeCode: PbFieldType.K6,
        pbDefaultOrMarker: Int64.ZERO,
      ),
    ScalarTypes.TYPE_UINT64 => scalarTypeReadWriteActions<Int64>(
        reader: (message) => message.$_getI64,
        writer: (message) => message.$_setInt64,
        pbFieldTypeCode: PbFieldType.OU6,
        pbRepeatedFieldTypeCode: PbFieldType.KU6,
        pbDefaultOrMarker: Int64.ZERO,
      ),
    ScalarTypes.TYPE_SINT64 => scalarTypeReadWriteActions<Int64>(
        reader: (message) => message.$_getI64,
        writer: (message) => message.$_setInt64,
        pbFieldTypeCode: PbFieldType.OS6,
        pbRepeatedFieldTypeCode: PbFieldType.KS6,
        pbDefaultOrMarker: Int64.ZERO,
      ),
    ScalarTypes.TYPE_FIXED64 => scalarTypeReadWriteActions<Int64>(
        reader: (message) => message.$_getI64,
        writer: (message) => message.$_setInt64,
        pbFieldTypeCode: PbFieldType.OF6,
        pbRepeatedFieldTypeCode: PbFieldType.KF6,
        pbDefaultOrMarker: Int64.ZERO,
      ),
    ScalarTypes.TYPE_SFIXED64 => scalarTypeReadWriteActions<Int64>(
        reader: (message) => message.$_getI64,
        writer: (message) => message.$_setInt64,
        pbFieldTypeCode: PbFieldType.OSF6,
        pbRepeatedFieldTypeCode: PbFieldType.KSF6,
        pbDefaultOrMarker: Int64.ZERO,
      ),
    ScalarTypes.TYPE_UINT32 => scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setUnsignedInt32,
        pbFieldTypeCode: PbFieldType.OU3,
        pbRepeatedFieldTypeCode: PbFieldType.KU3,
      ),
    ScalarTypes.TYPE_FIXED32 => scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setUnsignedInt32,
        pbFieldTypeCode: PbFieldType.OF3,
        pbRepeatedFieldTypeCode: PbFieldType.KF3,
      ),
    ScalarTypes.TYPE_BOOL => scalarTypeReadWriteActions<bool>(
        reader: (message) => message.$_getBF,
        writer: (message) => message.$_setBool,
        pbFieldTypeCode: PbFieldType.OB,
        pbRepeatedFieldTypeCode: PbFieldType.KB,
      ),
    ScalarTypes.TYPE_STRING => scalarTypeReadWriteActions<String>(
        reader: (message) => message.$_getSZ,
        writer: (message) => message.$_setString,
        pbFieldTypeCode: PbFieldType.OS,
        pbRepeatedFieldTypeCode: PbFieldType.PS,
      ),
    ScalarTypes.TYPE_BYTES => scalarTypeReadWriteActions<Bytes>(
        reader: (message) => message.$_getN,
        writer: (message) => message.$_setBytes,
        pbFieldTypeCode: PbFieldType.OY,
        pbRepeatedFieldTypeCode: PbFieldType.PY,
      ),
    _ => throw scalarTypeEnm,
  };
}

SingleTypeReadWrite<T> enumOrMessageSingleTypeReadWrite<T extends Object>({
  required MessageCtx messageCtx,
}) {
  return ComposedSingleTypeReadWrite(
    readFieldValue: singleReadFieldValue(
      readFieldValue: (message, fieldIndex) => message.$_getN(fieldIndex),
    ),
    writeFieldValue: singleWriteFieldValue(
      writeFieldValue: (message, fieldCoordinates, value) {
        message.setField(
          fieldCoordinates.tagNumberValue,
          value,
        );
      },
    ),
    singleTypeGeneric: genericFunction1<Object, T>(),
  );
}

SingleTypeReadWrite<V> singleTypeReadWriteActions<V extends Object>({
  required V Function(FieldIndex fieldIndex) Function(
    Msg message,
  ) reader,
  required void Function(FieldIndex fieldIndex, V value) Function(
    Msg message,
  ) writer,
}) {
  return ComposedSingleTypeReadWrite(
    readFieldValue: singleReadFieldValue(
      readFieldValue: (message, fieldIndex) {
        return reader(message).call(fieldIndex);
      },
    ),
    writeFieldValue: singleWriteFieldValue(
      writeFieldValue: (message, fieldCoordinates, value) {
        return writer(message).call(
          fieldCoordinates.fieldIndex,
          value,
        );
      },
    ),
    singleTypeGeneric: genericFunction1(),
  );
}

ScalarTypeActions<V> scalarTypeReadWriteActions<V extends Object>({
  required V Function(FieldIndex fieldIndex) Function(
    Msg message,
  ) reader,
  required void Function(FieldIndex fieldIndex, V value) Function(
    Msg message,
  ) writer,
  required PbFieldTypeCode pbFieldTypeCode,
  required PbRepeatedFieldTypeCode pbRepeatedFieldTypeCode,
  PbDefaultOrMarker pbDefaultOrMarker,
}) {
  return ComposedScalarTypeActions.singleTypeReadWrite(
    singleTypeReadWrite: singleTypeReadWriteActions(
      reader: reader,
      writer: writer,
    ),
    pbFieldTypeCode: pbFieldTypeCode,
    pbRepeatedFieldTypeCode: pbRepeatedFieldTypeCode,
    pbDefaultOrMarker: pbDefaultOrMarker,
  );
}

ReadFieldValue<V?> singleReadFieldValue<V extends Object>({
  @ext required ReadFieldValue<V> readFieldValue,
}) {
  return (message, fieldIndex) {
    if (!message.$_has(fieldIndex)) {
      return null;
    }

    return readFieldValue(message, fieldIndex);
  };
}

WriteFieldValue<V?> singleWriteFieldValue<V extends Object>({
  @ext required WriteFieldValue<V> writeFieldValue,
}) {
  return (message, fieldCoordinates, value) {
    if (value == null) {
      message.clearField(
        fieldCoordinates.tagNumberValue,
      );
    } else {
      writeFieldValue(
        message,
        fieldCoordinates,
        value,
      );
    }
  };
}

void singleTypeAddBuilderInfoField({
  @ext required FieldCtx fieldCtx,
  @ext required SingleTypeActions singleTypeActions,
  @ext required BuilderInfo builderInfo,
}) {
  singleTypeActions.singleTypeGeneric(
    <F extends Object>() {
      builderInfo.add<F>(
        fieldCtx.fieldMsg.fieldInfo.tagNumber,
        fieldCtx.fieldMsg.fieldInfo.description.jsonName,
        singleTypeActions.pbFieldTypeCode,
        singleTypeActions.pbDefaultOrMarker,
        singleTypeActions.pbCreateBuilderFunc,
        singleTypeActions.pbValueOfFunc,
        singleTypeActions.pbEnumValues,
        protoName: fieldCtx.fieldMsg.fieldInfo.description.protoName,
      );
    },
  );
}

void fieldCtxAddBuilderInfoField({
  @ext required FieldCtx fieldCtx,
  @ext required BuilderInfo builderInfo,
}) {
  final typeActions = fieldCtx.typeActions;

  switch (typeActions) {
    case SingleTypeActions():
      singleTypeAddBuilderInfoField(
        fieldCtx: fieldCtx,
        singleTypeActions: typeActions,
        builderInfo: builderInfo,
      );
    case RepeatedTypeActions():
      final singleTypeActions = typeActions.collectionElementTypeActions;
      final fieldTypeCode = singleTypeActions.pbRepeatedFieldTypeCode;
      singleTypeActions.singleTypeGeneric(<V extends Object>() {
        builderInfo.addRepeated<V>(
          fieldCtx.fieldMsg.fieldInfo.tagNumber,
          fieldCtx.fieldMsg.fieldInfo.description.jsonName,
          fieldTypeCode,
          getCheckFunction(fieldTypeCode),
          singleTypeActions.pbCreateBuilderFunc,
          singleTypeActions.pbValueOfFunc,
          singleTypeActions.pbEnumValues,
          defaultEnumValue: singleTypeActions.pbDefaultEnumValue,
          protoName: fieldCtx.fieldMsg.fieldInfo.description.protoName,
        );
      });

    case MapTypeActions():
      final singleTypeActions = typeActions.collectionElementTypeActions;
      final entryClassName = [
        ...fieldCtx.messageCtxPath(),
        "${fieldCtx.fieldMsg.fieldInfo.description.jsonName}Entry".pascalCase,
      ].join('.');

      typeActions.mapKeyTypeActions.singleTypeGeneric(<K extends Object>() {
        singleTypeActions.singleTypeGeneric(<V extends Object>() {
          builderInfo.m<K, V>(
            fieldCtx.fieldMsg.fieldInfo.tagNumber,
            fieldCtx.fieldMsg.fieldInfo.description.jsonName,
            keyFieldType: typeActions.mapKeyTypeActions.pbFieldTypeCode,
            valueFieldType: singleTypeActions.pbFieldTypeCode,
            valueCreator: singleTypeActions.pbCreateBuilderFunc,
            enumValues: singleTypeActions.pbEnumValues,
            defaultEnumValue: singleTypeActions.pbDefaultEnumValue,
            valueOf: singleTypeActions.pbValueOfFunc,
            valueDefaultOrMaker: singleTypeActions.pbDefaultOrMarker,
            protoName: fieldCtx.fieldMsg.fieldInfo.description.protoName,
            entryClassName: entryClassName,
          );
        });
      });
  }
}
