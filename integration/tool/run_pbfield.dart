import 'package:mhu_dart_model/src/generated/mhu_dart_model.pblib.dart';
import 'package:mhu_dart_model_example/src/generated/mhu_dart_model_example.pblib.dart';
import 'package:mhu_dart_pbgen/mhu_dart_pbgen.dart';

void main() async {
  await runPbFieldGenerator(
    lib: mhuDartModelExampleLib,
  );
}