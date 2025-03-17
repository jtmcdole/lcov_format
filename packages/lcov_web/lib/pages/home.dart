import 'dart:async';

import 'package:jaspr/ui.dart';
import 'dart:convert';
import 'package:lcov_format/lcov.dart';
import 'package:lcov_web/components/file_list.dart';
import 'package:lcov_web/utils/download_data.dart';
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart' as high;

final controller = StreamController<(String file, LcovRecord node)>();

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section([
      h1([text('</> LCOV')]),
      HomeGuts(),
    ]);
    yield FileHighlight(controller.stream);
  }
}

class HomeGuts extends StatefulComponent {
  const HomeGuts({super.key});

  @override
  State<HomeGuts> createState() => _HomeState();
}

class _HomeState extends State<HomeGuts> {
  late Future future;

  @override
  void initState() {
    super.initState();

    future = _loadState();
  }

  bool ready = false;
  var rootData = <String, dynamic>{};
  var maps = <String, Map<String, dynamic>>{};
  var paths = <String>[];

  Future _loadState() async {
    final body = await downloadSource('root.js');
    rootData = json.decode(body);

    paths.clear();
    maps = <String, Map<String, dynamic>>{};
    for (var MapEntry(:key, :value) in rootData.entries) {
      paths.add(key);
      maps[key] = value as Map<String, dynamic>;
    }
    paths.sort();
    setState(() {
      ready = true;
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (!ready) {
      yield text('loading');
      return;
    }

    yield FileList([
      for (final path in paths)
        (path: path, record: LcovRecord.fromJson(rootData[path]['lcov']))
    ], (String path) {
      log.info('selected: $path, ${rootData[path]}');
      controller.add((
        rootData[path]['highlights'],
        LcovRecord.fromJson(rootData[path]['lcov'])
      ));
    });
  }

  String? selectedFile;
}

class FileHighlight extends StatefulComponent {
  final Stream<(String path, LcovRecord node)> updates;
  FileHighlight(this.updates);

  @override
  State<FileHighlight> createState() => _FileHighlight();
}

class _FileHighlight extends State<FileHighlight> {
  late Future loading;

  high.TextSpan? spans;
  String path = '';
  LcovRecord? node;

  @override
  void initState() {
    component.updates.listen((record) async {
      node = record.$2;
      final downloadedSpans = json.decode(await downloadSource(record.$1));
      setState(() {
        spans = high.TextSpan.fromJson(downloadedSpans);
      });
    });
    super.initState();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (spans == null) {
      return;
    }
    final comp = <Component>[];

    int lineCount = 1;
    high.SpanVisitor(
      (textSpan, depth) {
        final string = textSpan.text;
        if (string == null) return;
        lineCount += ('\n'.allMatches(string)).length;

        final argb = textSpan.style?.foreground.argb ?? 0xFFFFFFFF;
        final hex = argb.toRadixString(16).substring(2);
        comp.add(
          span(
            [text(string)],
            // TODO: use css classes for overriding
            styles: argb == 0xFFFFFFFF
                ? null
                : Styles(
                    color: Color.hex('#$hex'),
                  ),
          ),
        );
      },
    ).visit(spans!);

    final cov = <Component>[];
    for (int i = 1; i < lineCount; i++) {
      final hits = node!.lines[i];
      cov.add(
        div(
          [
            text(hits == null ? '        ' : '$hits'.padLeft(8, ' ')),
          ],
          classes: hits == null
              ? ''
              : hits == 0
                  ? 'bad'
                  : 'good',
        ),
      );
    }

    yield div(
      [
        div(
          [Column(children: cov)],
          classes: 'highlight-lines',
        ),
        div(
          comp,
          classes: 'highlight-content',
        ),
      ],
      classes: 'file-highlight',
      id: 'file-highlight',
    );
  }
}
