part of 'proto_schema.dart';

@Has()
typedef SingleTypeGeneric = GenericFunction1<Object>;

@Has()
sealed class TypeActions<V> implements HasReadFieldValue<V> {}

sealed class SingleTypeActions<V extends Object>
    implements
        TypeActions<V?>,
        HasWriteFieldValue<V?>,
        HasSingleTypeGeneric {}

@Compose()
abstract class ScalarTypeActions<V extends Object>
    implements SingleTypeActions<V> {}

@Compose()
abstract class MessageTypeActions implements SingleTypeActions<GenericMsg> {}

@Compose()
abstract class EnumTypeActions implements SingleTypeActions<ProtobufEnum> {}

sealed class CollectionTypeActions<C extends Object, E extends Object>
    implements TypeActions<C>, HasSingleTypeGeneric {}

@Compose()
abstract class RepeatedTypeActions<V extends Object>
    implements CollectionTypeActions<List<V>, V> {}

@Compose()
abstract class MapTypeActions<K extends Object, V extends Object>
    implements CollectionTypeActions<Map<K, V>, V> {}

TypeActions fieldMsgTypeActions({
  @ext required FieldMsg fieldMsg,
}) {
  switch (fieldMsg.type) {
    case MpbFieldMsg_Type$singleType(:final singleType):
      return singleType.singleTypeActions();
    case MpbFieldMsg_Type$repeatedType(:final repeatedType):
      final singleActions = repeatedType.singleType.singleTypeActions();
      return singleActions.singleTypeGeneric(
        <V extends Object>() {
          return ComposedRepeatedTypeActions<V>(
            readFieldValue: (message, fieldIndex) =>
                message.$_getList(fieldIndex),
            singleTypeGeneric: genericFunction1(),
          );
        },
      );
    case MpbFieldMsg_Type$mapType(:final mapType):
      final keyTypeEnm = MpbScalarTypeEnm.valueOf(
        mapType.keyType.value,
      )!;
      final valueActions = mapType.valueType.singleTypeActions();
      return keyTypeEnm.scalarTypeActions().singleTypeGeneric(
        <K extends Object>() {
          return valueActions.singleTypeGeneric(
            <V extends Object>() {
              return ComposedMapTypeActions<K, V>(
                readFieldValue: (message, fieldIndex) =>
                    message.$_getMap(fieldIndex),
                singleTypeGeneric: genericFunction1(),
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
}) {
  return switch (singleType.type) {
    MpbSingleTypeMsg_Type$scalarType(:final scalarType) =>
      // ignore: unnecessary_cast
      scalarType.scalarTypeActions() as SingleTypeActions,
    MpbSingleTypeMsg_Type$enumType() =>
      ComposedEnumTypeActions.singleTypeActions(
        singleTypeActions: enumOrMessageSingleTypeActions(),
      ),
    MpbSingleTypeMsg_Type$messageType() =>
      ComposedMessageTypeActions.singleTypeActions(
        singleTypeActions: enumOrMessageSingleTypeActions(),
      ),
    _ => throw singleType,
  };
}

ScalarTypeActions scalarTypeActions({
  @ext required MpbScalarTypeEnm scalarTypeEnm,
}) {
  return switch (scalarTypeEnm) {
    ScalarTypes.TYPE_DOUBLE => scalarTypeReadWriteActions<double>(
        reader: (message) => message.$_getN,
        writer: (message) => message.$_setDouble,
      ),
    ScalarTypes.TYPE_FLOAT => scalarTypeReadWriteActions<double>(
        reader: (message) => message.$_getN,
        writer: (message) => message.$_setFloat,
      ),
    ScalarTypes.TYPE_INT32 ||
    ScalarTypes.TYPE_SINT32 ||
    ScalarTypes.TYPE_SFIXED32 =>
      scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setSignedInt32,
      ),
    ScalarTypes.TYPE_INT64 ||
    ScalarTypes.TYPE_UINT64 ||
    ScalarTypes.TYPE_SINT64 ||
    ScalarTypes.TYPE_FIXED64 ||
    ScalarTypes.TYPE_SFIXED64 =>
      scalarTypeReadWriteActions<Int64>(
        reader: (message) => message.$_getI64,
        writer: (message) => message.$_setInt64,
      ),
    ScalarTypes.TYPE_UINT32 ||
    ScalarTypes.TYPE_FIXED32 =>
      scalarTypeReadWriteActions<int>(
        reader: (message) => message.$_getIZ,
        writer: (message) => message.$_setUnsignedInt32,
      ),
    ScalarTypes.TYPE_BOOL => scalarTypeReadWriteActions<bool>(
        reader: (message) => message.$_getBF,
        writer: (message) => message.$_setBool,
      ),
    ScalarTypes.TYPE_STRING => scalarTypeReadWriteActions<String>(
        reader: (message) => message.$_getSZ,
        writer: (message) => message.$_setString,
      ),
    ScalarTypes.TYPE_BYTES => scalarTypeReadWriteActions<Bytes>(
        reader: (message) => message.$_getN,
        writer: (message) => message.$_setBytes,
      ),
    _ => throw scalarTypeEnm,
  };
}

ScalarTypeActions<T> enumOrMessageSingleTypeActions<T extends Object>() {
  return ComposedScalarTypeActions<T>(
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

ScalarTypeActions<V> scalarTypeReadWriteActions<V extends Object>({
  required V Function(FieldIndex fieldIndex) Function(
    Msg message,
  ) reader,
  required void Function(FieldIndex fieldIndex, V value) Function(
    Msg message,
  ) writer,
}) {
  return ComposedScalarTypeActions<V>(
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
