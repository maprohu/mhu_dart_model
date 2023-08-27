// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proto_schema.dart';

// **************************************************************************
// DelegateHasClassGenerator
// **************************************************************************

abstract class HasMessageSchema {
  MessageSchema get messageSchema;
}

mixin MixMessageSchema implements HasMessageSchema {
  @override
  late final MessageSchema messageSchema;
}

extension HasMessageSchema$Ext on MessageSchema {
  void initMixMessageSchema(MixMessageSchema mix) {
    mix.messageSchema = this;
  }
}

typedef CallMessageSchema = MessageSchema Function();

abstract class HasCallMessageSchema {
  CallMessageSchema get callMessageSchema;
}

mixin MixCallMessageSchema implements HasCallMessageSchema {
  @override
  late final CallMessageSchema callMessageSchema;
}

extension HasCallMessageSchema$Ext on CallMessageSchema {
  void initMixCallMessageSchema(MixCallMessageSchema mix) {
    mix.callMessageSchema = this;
  }
}

abstract class HasMessageMsg {
  MessageMsg get messageMsg;
}

mixin MixMessageMsg implements HasMessageMsg {
  @override
  late final MessageMsg messageMsg;
}

extension HasMessageMsg$Ext on MessageMsg {
  void initMixMessageMsg(MixMessageMsg mix) {
    mix.messageMsg = this;
  }
}

typedef CallMessageMsg = MessageMsg Function();

abstract class HasCallMessageMsg {
  CallMessageMsg get callMessageMsg;
}

mixin MixCallMessageMsg implements HasCallMessageMsg {
  @override
  late final CallMessageMsg callMessageMsg;
}

extension HasCallMessageMsg$Ext on CallMessageMsg {
  void initMixCallMessageMsg(MixCallMessageMsg mix) {
    mix.callMessageMsg = this;
  }
}

abstract class HasFieldMsg {
  FieldMsg get fieldMsg;
}

mixin MixFieldMsg implements HasFieldMsg {
  @override
  late final FieldMsg fieldMsg;
}

extension HasFieldMsg$Ext on FieldMsg {
  void initMixFieldMsg(MixFieldMsg mix) {
    mix.fieldMsg = this;
  }
}

typedef CallFieldMsg = FieldMsg Function();

abstract class HasCallFieldMsg {
  CallFieldMsg get callFieldMsg;
}

mixin MixCallFieldMsg implements HasCallFieldMsg {
  @override
  late final CallFieldMsg callFieldMsg;
}

extension HasCallFieldMsg$Ext on CallFieldMsg {
  void initMixCallFieldMsg(MixCallFieldMsg mix) {
    mix.callFieldMsg = this;
  }
}
