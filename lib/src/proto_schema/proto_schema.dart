import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mhu_dart_annotation/mhu_dart_annotation.dart';
import 'package:mhu_dart_commons/commons.dart';
import 'package:mhu_dart_model/mhu_dart_model.dart';
import 'package:mhu_dart_proto/mhu_dart_proto.dart';
import 'package:protobuf/protobuf.dart';
import 'package:recase/recase.dart';

import 'proto_schema.dart' as $lib;

part 'proto_schema.g.has.dart';

part 'proto_schema.g.dart';

part 'proto_schema.freezed.dart';

part 'message.dart';

part 'enum.dart';

part 'logical_field.dart';

part 'field.dart';

part 'type.dart';

part 'oneof.dart';

part 'descriptor.dart';

part 'generated_message.dart';

part 'resolve.dart';

part 'schema.dart';


@Has()
typedef MessageMsg = MpbMessageMsg;

@Has()
typedef EnumMsg = MpbEnumMsg;

@Has()
typedef FieldMsg = MpbFieldMsg;

@Has()
typedef LogicalFieldMsg = MpbLogicalFieldMsg;

@Has()
typedef ReferenceMsg = MpbReferenceMsg;

@Has()
typedef OneofMsg = MpbOneofMsg;


// @Compose()
// abstract class SchemaCollection implements HasMessageLookup {}
