import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';

import 'proto_schema.dart' as $lib;

part 'proto_schema.g.has.dart';

part 'proto_schema.g.dart';

@Has()
typedef MessageMsg = MpbMessageMsg;

@Has()
typedef FieldMsg = MpbFieldMsg;

@Compose()
@Has()
abstract class MessageSchema implements HasMessageMsg {}

@Compose()
abstract class FieldSchema implements HasFieldMsg {}
