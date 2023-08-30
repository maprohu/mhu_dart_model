import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:mhu_dart_model/src/proto_schema/proto_schema.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';
import 'package:test/test.dart';

void main() {
  test('proto schema', () {
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

    final schemaCtx = ComposedSchemaCtx();

    final messages = schemaCollection.messages;

    final dimensionMsg = messages.singleWhere(
      (e) => e.msg.description.name == (CmnDimensionsMsg).toString(),
    );

    final dimensionCtx = schemaCtx.createMessageCtx(
      messageMsg: dimensionMsg.msg,
      referenceMsg: dimensionMsg.reference,
    );

    final widthCtx = dimensionCtx.callLogicalFieldsList().singleWhere(
          (e) => e.fieldName == CmnDimensionsMsg$.width.name,
        );

    widthCtx as FieldCtx;

    final dimensionWidth1 = CmnDimensionsMsg$.create(
      width: 1,
    )..freeze();

  });
}
