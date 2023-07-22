
import 'package:mhu_dart_builder/mhu_dart_builder.dart';
import 'package:mhu_dart_model/src/generated/mhu_dart_model.pblib.dart';

void main() async {
  await runPbFieldGenerator(lib: mhuDartModelLib);
}
