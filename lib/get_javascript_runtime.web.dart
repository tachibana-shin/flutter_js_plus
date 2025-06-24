import 'package:flutter_js/web_worker_runtime.dart';

import 'ab_javascript_runtime.dart';

JavascriptRuntime getJavascriptRuntime({
  bool forceJavascriptCoreOnAndroid = false,
  bool xhr = true,
  Map<String, dynamic>? extraArgs = const {},
}) {
  return WorkerJSRuntime();
}
