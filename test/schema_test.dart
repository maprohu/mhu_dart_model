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

    


  });
}
