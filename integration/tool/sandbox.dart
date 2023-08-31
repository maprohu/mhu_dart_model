import 'dart:io';

import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:mhu_dart_model_example/proto.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';
import 'package:protobuf/protobuf.dart';

void main() async {
  final descriptorFile = File("proto/generated/descriptor.pb.bin");
  final fileDescriptorSet =
      descriptorFile.readAsBytesSync().let(FileDescriptorSet.fromBuffer);

  final schemaLookupByName = await fileDescriptorSet.descriptorSchemaLookupByName();

  final fieldTypesCtx = schemaLookupByName.lookupMessageCtxOfType<TstFieldTypesMsg>();

  final int32ValueAccess = TstFieldTypesMsg$.int32Value;

  final fieldTypesMsg1 = TstFieldTypesMsg$.create(
    int32Value: 1,
  )..freeze();

  final logicalFields = fieldTypesCtx.callLogicalFieldsList();

  final int32ValueCtx = logicalFields.singleWhere(
    (e) => e.fieldProtoName == int32ValueAccess.protoName,
  );

  int32ValueCtx as FieldCtx;

  final typeActions = int32ValueCtx.typeActions as ScalarTypeActions<int>;

  final int32ValueFieldCoordinates = int32ValueCtx.callFieldCoordinates();

  final fieldTypesMsg2 = fieldTypesMsg1.rebuild(
    (msg) {
      typeActions.writeFieldValue(
        msg,
        int32ValueFieldCoordinates,
        2,
      );
    },
  );

  print(fieldTypesMsg2);

  assert(fieldTypesMsg2.int32Value == 2);

  final genericMsg = fieldTypesCtx.createGenericMsg()..freeze();

  final genericFieldTypesMsg3 = genericMsg.rebuild(
    (msg) {
      typeActions.writeFieldValue(
        msg,
        int32ValueFieldCoordinates,
        3,
      );
    },
  );

  print(genericFieldTypesMsg3);
}
