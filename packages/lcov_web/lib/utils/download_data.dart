@JS()

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:path/path.dart' as path;
import 'package:web/web.dart';
import 'package:logging/logging.dart';

final log = Logger('download');

Future<String> downloadSource(String source) async {
  final watch = Stopwatch()..start();

  final variable = 'lcov_data_${path.basenameWithoutExtension(source)}';
  final script = HTMLScriptElement()
    ..src = source
    ..type = "text/javascript"
    ..id = 'download_string';
  final future = script.onLoad.first;
  document.head!.append(script);

  await future;
  final compressedString = globalContext[variable]! as JSString;
  final compressedData = base64.decode(compressedString.toDart);
  final dcs = DecompressionStream('gzip');
  dcs.writable.getWriter()
    ..write(compressedData.toJS)
    ..close();

  final decompressedString = utf8.decode(
      (await Response(dcs.readable).arrayBuffer().toDart).toDart.asUint8List());
  watch.stop();
  log.info('download/decompressed in ${watch.elapsed}');

  script.parentElement!.removeChild(script);
  globalContext.delete(variable.toJS);

  return decompressedString;
}
