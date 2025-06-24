import 'dart:async';
import 'dart:ffi';

import 'js_eval_result.dart';
import 'ab_javascript_runtime.dart';

export 'ab_javascript_runtime.dart';

class FlutterJsPlatformEmpty extends JavascriptRuntime {
  @override
  JsEvalResult callFunction(Pointer<NativeType> fn, Pointer<NativeType> obj) {
    throw UnimplementedError();
  }

  @override
  T? convertValue<T>(JsEvalResult jsValue) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  JsEvalResult evaluate(String code, {String? sourceUrl}) {
    throw UnimplementedError();
  }

  @override
  Future<JsEvalResult> evaluateAsync(String code, {String? sourceUrl}) {
    throw UnimplementedError();
  }

  @override
  int executePendingJob() {
    throw UnimplementedError();
  }

  @override
  String getEngineInstanceId() {
    throw UnimplementedError();
  }

  @override
  void initChannelFunctions() {
    throw UnimplementedError();
  }

  @override
  String jsonStringify(JsEvalResult jsValue) {
    throw UnimplementedError();
  }

  @override
  bool setupBridge(String channelName, void Function(dynamic args) fn) {
    throw UnimplementedError();
  }

  @override
  void setInspectable(bool inspectable) {
    throw UnimplementedError();
  }
}
