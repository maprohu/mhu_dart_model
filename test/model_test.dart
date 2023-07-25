import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:test/test.dart';

void main() {
  test('create object with repeated field', () {
    final msg = CmnEnumTypeMsg$.create(
      options: {
        'x': CmnEnumOptionMsg$.create(
        ),
      },
    );

    expect(msg.options.keys.single, 'x');
  });
}
