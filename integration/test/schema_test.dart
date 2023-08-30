import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:mhu_dart_model_example/proto.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';
import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

void main() {
  test('proto schema', () async {
    final descriptorFile = File("proto/generated/descriptor.pb.bin");
    final fileDescriptorSet =
        descriptorFile.readAsBytesSync().let(FileDescriptorSet.fromBuffer);

    int referenceSequence = 0;
    final references = <TypeCoordinates, ReferenceMsg>{};

    final schemaCollection = fileDescriptorSet.descriptorSchemaCollection(
      messageReference: (typeCoordinates) {
        return references.putIfAbsent(
          typeCoordinates,
          () => MpbReferenceMsg$.create(
            referenceId: Int64(referenceSequence++),
          ),
        );
      },
    );

    final messages = schemaCollection.messages;

    final resolveLookup = {
      for (final message in schemaCollection.messages)
        message.reference: message.msg.writeToBuffer(),
      for (final enm in schemaCollection.enums)
        enm.reference: enm.msg.writeToBuffer(),
    };

    final resolveCtx = ComposedResolveCtx(
      resolveReference: (referencedMsg) async {
        return resolveLookup[referencedMsg] ?? (throw referencedMsg);
      },
    );

    final schemaBuilder = createSchemaBuilder(resolveCtx: resolveCtx);

    final fieldTypesMsg = messages.singleWhere(
      (e) => e.msg.description.protoName == (TstFieldTypesMsg).toString(),
    );


    final int32ValueAccess = TstFieldTypesMsg$.int32Value;



    final fieldTypesMsg1 = TstFieldTypesMsg$.create(
      int32Value: 1,
    )..freeze();

    final fieldTypesCtx =
        await schemaBuilder.registerMessage(fieldTypesMsg.reference);

    final logicalFields = fieldTypesCtx.callLogicalFieldsList();

    final int32ValueCtx = logicalFields.singleWhere(
          (e) => e.fieldProtoName == int32ValueAccess.protoName,
    );

    int32ValueCtx as FieldCtx;

    final typeActions = int32ValueCtx.typeActions as ScalarTypeActions<int>;

    final fieldTypesMsg2 = fieldTypesMsg1.rebuild(
      (msg) {
        typeActions.writeFieldValue(
          msg,
          int32ValueCtx.callFieldCoordinates(),
          2,
        );
      },
    );

    expect(fieldTypesMsg2.int32Value, 2);
  });
}
