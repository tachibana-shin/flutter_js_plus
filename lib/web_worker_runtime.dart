import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';
import 'package:flutter_js/js_eval_result.dart';
import 'package:web/web.dart' as web;

import 'ab_javascript_runtime.dart';

class WorkerJSRuntime extends JavascriptRuntime {
  late final web.Worker _worker;
  final _bridge = <String, List<Function>>{};
  final _pending = <int, Completer<JsEvalResult>>{};
  int _messageId = 0;

  WorkerJSRuntime() {
    final jsCode = '''
      const bridge = new Map()
      self.onMessage = function (name, fn) {
        let list = bridge.set(name)
        if (!list) bridge.set(name, list = [])
        list.push(fn)
      }
      self.sendMessage = function(name, args) {
        self.postMessage({ channelName: name, args: args })
      }
      self.onmessage = async function(event) {
        if (event.data.channel) {
          bridge.get(event.data.channel)?.forEach(fn => fn(event.data.args))
          return
        }
        const { id, command } = event.data;
        try {
          const result = await eval(command);
          self.postMessage({ id, result });
        } catch (e) {
          self.postMessage({ id, error: e.toString() });
        }
      };
    ''';

    final blob = web.Blob(
      [jsCode.toJS].toJS,
      web.BlobPropertyBag(type: 'application/javascript'),
    );
    final url = web.URL.createObjectURL(blob).toJS;

    _worker = web.Worker(url);

    _worker.onmessage = (web.Event e) {
      final data = (e as web.MessageEvent).data as JSObject;

      if (!data['channelName'].isUndefined) {
        _bridge[data['channelName']]?.forEach((cb) => cb.call(data['args']));
        return;
      }

      final id = data['id'] as JSNumber;
      final result = data['result'] as JSAny;
      final error = data['error'] as JSAny;

      final completer = _pending.remove(id.toDartInt);
      if (completer == null) return;

      if (!error.isUndefined) {
        completer.complete(
          JsEvalResult(error.toString(), null, isError: true),
        );
      } else {
        completer.complete(
          JsEvalResult(result.toString(), result.toString()),
        );
      }
    }.toJS;
  }

  @protected
  JavascriptRuntime init() {
    return this;
  }

  @override
  Future<JsEvalResult> evaluateAsync(String code, {String? sourceUrl}) {
    final id = _messageId++;
    final completer = Completer<JsEvalResult>();
    _pending[id] = completer;

    _worker.postMessage({
      'id': id,
      'command': code,
    }.toJSBox);

    return completer.future;
  }

  @override
  JsEvalResult evaluate(String command,
      {String? name, int? evalFlags, String? sourceUrl}) {
    throw UnimplementedError('Use evaluateAsync on WorkerJSRuntime.');
  }

  @override
  void dispose() {
    _worker.terminate();
  }

  @override
  void setInspectable(bool inspectable) {
    // No-op
  }

  @override
  int executePendingJob() => 0;

  @override
  String getEngineInstanceId() => hashCode.toString();

  @override
  void initChannelFunctions() {
    // No-op
  }

  @override
  String jsonStringify(JsEvalResult jsValue) {
    return jsonEncode(jsValue.rawResult);
  }

  @override
  T? convertValue<T>(JsEvalResult jsValue) {
    return jsValue.rawResult as T?;
  }

  sendMessage({
    required String channelName,
    required List<String> args,
    String? uuid,
  }) {
    _worker.postMessage({
      'channel': channelName,
      'uuid': uuid,
      'args': args,
    }.toJSBox);
  }

  onMessage(String channelName, dynamic Function(dynamic args) fn) {
    setupBridge(channelName, fn);
  }

  bool setupBridge(String channelName, void Function(dynamic args) fn) {
    _bridge.putIfAbsent(channelName, () => []).add(fn);
    return true;
  }

  @override
  JsEvalResult callFunction(fn, obj) {
    throw UnimplementedError();
  }
}
