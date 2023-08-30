part of 'proto_schema.dart';

class GenericMsg extends Msg {
  GenericMsg({
    required BuilderInfo info,
  }) : info_ = info;

  @override
  GenericMsg clone() => GenericMsg(info: info_)..mergeFromMessage(this);

  @override
  GenericMsg createEmptyInstance() => GenericMsg(info: info_);

  @override
  final BuilderInfo info_;
}

BuilderInfo genericBuilderInfo({
  @extHas required MessageMsg messageMsg,
}) {
  return BuilderInfo(null);
}

GenericMsg createGenericMsg({
  @extHas required MessageMsg messageMsg,
}) {
  return GenericMsg(
    info: messageMsg.genericBuilderInfo(),
  );
}
