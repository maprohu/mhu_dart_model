import 'dart:io';

import 'package:mhu_dart_builder/mhu_dart_builder.dart';
import 'package:mhu_dart_commons/io.dart';

void main() async {
  final packageName = 'mhu_dart_model';
  await runProtoc(packageName);
  final cwd = Directory.current;

  final metaFile = cwd.protoMetaFile(packageName);


  final content = [
    r"import 'dart:core' as $core;",
    r"import 'package:fixnum/fixnum.dart' as $fixnum;",
    r"import 'package:mhu_dart_commons/commons.dart' as $commons;",
    r"import 'package:mhu_dart_proto/mhu_dart_proto.dart' as $proto_meta;",
    r"import 'package:protobuf/protobuf.dart' as $protobuf;",
    r"import 'package:fast_immutable_collections/fast_immutable_collections.dart';",
    "import '${cwd.pbFile(packageName).filename}';",
    generateProtoMeta(
      'MhuModel',
      Directory.current.file('proto/generated/descriptor').readAsBytesSync(),
    ),
  ];

  await metaFile.writeAsString(
    content.join("\n").formattedDartCode(),
  );
  stdout.writeln(
    "wrote: ${metaFile.uri}",
  );

}
