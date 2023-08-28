import 'dart:io';

import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';
import 'package:test/test.dart';

void main() {
  test('proto schema', () {
    final descriptorFile = File("proto/generated/descriptor.pb.bin");
    final fileDescriptorSet =
        descriptorFile.readAsBytesSync().let(FileDescriptorSet.fromBuffer);

    print(fileDescriptorSet);
  });
}
