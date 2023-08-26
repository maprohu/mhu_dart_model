import 'dart:io';

import 'package:mhu_dart_commons/io.dart';
import 'run_pblib.dart' as pblib;

void main() async {
  await pblib.main();

  await Directory.current.run(
    'dart',
    [
      'tool/run_pbfield.dart',
    ],
  );
}
