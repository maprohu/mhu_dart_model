import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';

import 'proto_schema.dart' as $lib;

part 'proto_schema.g.has.dart';

part 'proto_schema.g.dart';

part 'message.dart';

part 'logical_field.dart';

part 'field.dart';

part 'oneof.dart';

part 'descriptor.dart';

@Has()
@Compose()
abstract class SchemaCtx {}

@Has()
typedef MessageMsg = MpbMessageMsg;

@Has()
typedef FieldMsg = MpbFieldMsg;

@Has()
typedef LogicalFieldMsg = MpbLogicalFieldMsg;

@Has()
typedef ReferenceMsg = MpbReferenceMsg;

@Has()
typedef OneofMsg = MpbOneofMsg;

@Has()
typedef MessageLookup = IMap<MpbReferenceMsg, MessageCtx>;

@Compose()
abstract class SchemaCollection implements HasMessageLookup {}
