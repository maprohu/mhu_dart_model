part of 'proto_schema.dart';

SchemaCollection descriptorSchemaCollection({
  required FileDescriptorSet fileDescriptorSet,
  required ReferenceMsg Function(
    FileDescriptorProto fileDescriptor,
    DescriptorProto messageDescriptor,
  ) createReference,
}) {
  final messages = <MessageCtx>[];

  final schemaCtx = ComposedSchemaCtx();

  MessageMsg createMessageMsg({
    required DescriptorProto messageDescriptor,
    MpbReferenceMsg? enclosingMessage,
  }) {
    return MpbMessageMsg$.create(
      description: MpbDescriptionMsg$.create(
        name: messageDescriptor.name,
      ),
      enclosingMessage: enclosingMessage,
    );
  }

  for (final fileDescriptor in fileDescriptorSet.file) {
    for (final messageDescriptor in fileDescriptor.messageType) {
      final referenceMsg = createReference(
        fileDescriptor,
        messageDescriptor,
      );

      final messageCtx = createMessageCtx(
        schemaCtx: schemaCtx,
        messageMsg: createMessageMsg(messageDescriptor: messageDescriptor),
        referenceMsg: referenceMsg,
      );
    }
  }
}
